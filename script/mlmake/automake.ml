#!/usr/bin/ocaml

#use "mlmake/target.ml"
#use "OMakefile.ml"

open Format
module StringSet = Set.Make(String)


let uniq l =
  List.fold_left (flip StringSet.add) StringSet.empty l
  |> StringSet.elements


let print_list f out =
  List.iter (fprintf out "%a@," f)

let print_flag out (key, value) =
  fprintf out "$|%s| = %s" key value

let print_array out name f = function
  | [e] ->
      fprintf out "%s = %a@," name f e
  | l ->
      fprintf out "@[<v2>%s[] =@,%a@]@," name (print_list f) l

let print_decls out =
  List.iter (function
    | Name s
    | AldorName s
    | Description s
    | Version s as decl ->
        fprintf out "%s = %s@," (name_of_decl decl) s

    | AldorRequires l
    | OCamlRequires l
    | OCamlIncludes l
    | Includes l
    | Interfaces l
    | CRequires l
    | Sources l
    | Headers l
    | Grammars l
    | Tokens l
    | Domains l
    | InternalDomains l
    | Array (_, l)
    | Modules l as decl ->
        print_array out (name_of_decl decl) pp_print_string l

    | Flags l as decl ->
        fprintf out "@[<v2>%s. +=@,%a@]@,"
          (name_of_decl decl)
          (print_list print_flag) l

    | Var (_, s) as decl ->
        fprintf out "%s = %s@," (name_of_decl decl) s

    | Code code ->
        fprintf out "%s@," code

    | Parser (_, s)
    | Recurse s as decl ->
        fprintf out "%s (%s)@," (name_of_decl decl) s
  )


let library_install out tag =
  fprintf out "library-install (%s)@," tag;
;;

let syntax_install out tag =
  fprintf out "syntax-extension-install (%s)@," tag;
;;

let program_install out tag =
  fprintf out "program-install (%s)@," tag;
;;

let package_install out tag =
  fprintf out "ocaml-pack-install (%s)@," tag;
;;

let string_of_target_kind = function
  | Library -> "library"
  | Package -> "ocaml-pack"
  | Program -> "program"
  | Syntax -> "syntax-extension"

let string_of_target_action = function
  | Install -> "-install"
  | Build -> ""

let print_languages out target =
  print_array out "Languages" pp_print_string
    (List.map string_of_language target.langs |> uniq);
  fprintf out "MainLanguage = %s@,"
    (string_of_language target.lang)

let print_target out target =
  fprintf out "%a@,%a@,%s%s (%s)"
    print_decls target.decls
    print_languages target
    (string_of_target_kind target.kind)
    (string_of_target_action target.action)
    target.tag


let print_section out target =
  fprintf out "@[<v2>section:@,%a@]@,"
    print_target target


let print_header out =
  fprintf out "# Generated from OMakefile.ml@,"
  (*fprintf out "echo $(fullname .)@,"*)


let makefile () =
  match Sys.argv with
  | [|_; file|] ->
      formatter_of_out_channel (open_out file)
  | _ ->
      failwith "Need output file"

let () =
  match !targets with
  | [] ->
      failwith "no targets";
  | [single] ->
      let out = makefile () in
      print_header out;
      fprintf out "@[<v>%a@]@." print_target single
  | targets ->
      let out = makefile () in
      print_header out;
      fprintf out "@[<v>%a@]@." (print_list print_section) targets
