let trace = 0 = 1
open Ast

let string_of_token = let open Parser in function
  | EOF -> "EOF"
  | EOL -> "EOL"
  | LPAREN -> "LPAREN"
  | RPAREN -> "RPAREN"
  | COMMA -> "COMMA"
  | EQUAL -> "EQUAL"
  | ADDEQUAL -> "ADDEQUAL"
  | COLON -> "COLON"
  | VAR_OPEN -> "VAR_OPEN"
  | VAR_CLOSE -> "VAR_CLOSE"
  | KEY_OPEN -> "KEY_OPEN"
  | KEY_CLOSE -> "KEY_CLOSE"

  | KW_Name -> "KW_Name"
  | KW_Description -> "KW_Description"
  | KW_Flags -> "KW_Flags"
  | KW_Requires s -> "KW_Requires " ^ (Sexplib.Sexp.to_string_hum (sexp_of_language s))
  | KW_Sources s -> "KW_Sources " ^ (Sexplib.Sexp.to_string_hum (sexp_of_language s))
  | KW_Headers s -> "KW_Headers " ^ (Sexplib.Sexp.to_string_hum (sexp_of_language s))
  | KW_include s -> "KW_include " ^ s

  | INDENT i -> "INDENT " ^ string_of_int i
  | VAR c -> "VAR " ^ (Char.escaped c)
  | ARRAY s -> "ARRAY " ^ s
  | OBJECT s -> "OBJECT " ^ s
  | BUILTIN s -> "BUILTIN " ^ s
  | NAME s -> "NAME " ^ s
  | WORD s -> "WORD " ^ s


let string_of_feedback fn =
  if fn == Lexer.in_var then
    "in_var"
  else if fn == Lexer.in_key then
    "in_key"
  else if fn == Lexer.in_definition then
    "in_definition"
  else if fn == Lexer.token then
    "token"
  else
    "<unknown>"


let token lexbuf =
  let tok = !Feedback.token lexbuf in
  if trace then
    Printf.fprintf stderr "%s: %s\n"
      (string_of_feedback !Feedback.token)
      (string_of_token tok);
  tok


let detect_language tree =
  List.fold_left (fun langs lang ->
    if
      List.exists (function
        | Sources (lang', _)
        | Headers (lang', _)
        | Requires (lang', _) -> lang' = lang
        | _ -> false
      ) tree
    then
      lang :: langs
    else
      langs
  ) [] all_languages


let make_target tree =
  let languages = detect_language tree in
  let main_language =
    match List.sort compare languages with
    | [] -> failwith "no language detected"
    | lang :: _ -> lang
  in
  {
    tree;
    languages;
    main_language;
  }


let targets = Hashtbl.create 10


let split str separator =
  let rec split parts str =
    try
      let pos = String.index str separator in
      let part = String.sub str 0 pos in
      split
        (part :: parts)
        (String.sub str (pos + 1) (String.length str - pos - 1))
    with Not_found ->
      str :: parts
  in
  split [] str


let parse_file file =
  let channel = open_in file in
  begin try
    let lexbuf = Lexing.from_channel channel in
    let tree =
      try
        Parser.parse token lexbuf
      with Parser.StateError (tok, _) ->
        Lexer.error lexbuf ("parse error near " ^ string_of_token tok)
    in
    if List.exists (function Name _ -> true | _ -> false) tree then (
      Hashtbl.add targets file (make_target tree);
      if trace then
        prerr_endline (Sexplib.Sexp.to_string_hum (sexp_of_t tree));
    )
  with
  | Lexer.No_parse ->
      ()
  | e ->
      prerr_endline ("in file: " ^ file);
      prerr_endline (Printexc.to_string e);
      exit 1
  end;
  close_in channel


let parse_files files =
  List.iter parse_file (split files ',')


let language lang =
  let lang = language_of_string lang in
  fun target ->
    List.memq lang target.languages


let main_language langs target =
  List.exists (fun lang ->
    let lang = language_of_string lang in
    target.main_language = lang
  ) (split langs ',')


let target_kind kinds target =
  List.exists (fun kind ->
    List.exists (function
      | VarDefn ("TARGET", [FCall (kind', _)]) ->
          kind' = kind
      | _ -> false
    ) target.tree
  ) (split kinds ',')


let filter f x =
  let f = f x in
  Hashtbl.iter (fun file target ->
    if not (f target) then
      Hashtbl.remove targets file
  ) targets


let names () =
  let names =
    Hashtbl.fold (fun file target names ->
      List.fold_left (fun names -> function
        | Name name -> name :: names
        | _ -> names
      ) names target.tree
    ) targets []
  in
  print_endline (String.concat " " names)


let spec = Arg.(align [
  "-parse", String parse_files, "<files> parse comma separated list of OMakefiles";
  "-lang", String (filter language), "<lang> filter targets by language used";
  "-mainlang", String (filter main_language), "<lang> filter targets by main language";
  "-kind", String (filter target_kind), "<kind> filter targets library/program";
  "-names", Unit names, " print target names";
])

let () =
  Feedback.push Lexer.token;
  Arg.parse spec failwith "Usage: obuild"
