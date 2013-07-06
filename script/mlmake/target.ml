let (|>) f x = x f
let flip f a b = f b a


type parser_type =
  | Elkhound
  | Menhir

type decl =
  (* Variables *)
  | Name of string
  | AldorName of string
  | Description of string
  | Version of string
  | Domains of string list
  | InternalDomains of string list
  | Modules of string list
  | Grammars of string list
  | Tokens of string list
  | AldorRequires of string list
  | OCamlRequires of string list
  | OCamlIncludes of string list
  | Includes of string list
  | Interfaces of string list
  | CRequires of string list
  | Sources of string list
  | Headers of string list
  | Flags of (string * string) list
  | Code of string
  | Array of string * string list
  | Var of string * string
  (* Function calls *)
  | Recurse of string
  | Parser of parser_type * string


type target_action =
  | Build
  | Install

type target_type =
  | Library
  | Package
  | Program
  | Syntax

type language =
  | OCaml
  | Aldor
  | Cxx
  | C

type target = {
  action	: target_action;
  kind		: target_type;
  tag		: string;
  decls		: decl list;
  langs		: language list;
  lang		: language;
}


let string_of_language = function
  | OCaml -> "ocaml"
  | Aldor -> "aldor"
  | Cxx -> "cxx"
  | C -> "c"


let name_of_decl = function
  (* Variables *)
  | Name _ -> "Name"
  | AldorName _ -> "AldorName"
  | Description _ -> "Description"
  | Version _ -> "Version"
  | Domains _ -> "Domains"
  | InternalDomains _ -> "InternalDomains"
  | Modules _ -> "Modules"
  | Grammars _ -> "Grammars"
  | Tokens _ -> "Tokens"
  | AldorRequires _ -> "Aldor-Requires"
  | OCamlRequires _ -> "OCaml-Requires"
  | OCamlIncludes _ -> "OCAMLINCLUDES"
  | Includes _ -> "Includes"
  | Interfaces _ -> "Interfaces"
  | CRequires _ -> "C-Requires"
  | Sources _ -> "Sources"
  | Headers _ -> "Headers"
  | Flags _ -> "Flags"
  | Code _ -> failwith "Code has no name"
  | Array (name, _)
  | Var (name, _) -> name

  (* Function calls *)
  | Recurse _ -> "recurse"
  | Parser (Elkhound, _) -> "elkhound-parser"
  | Parser (Menhir, _) -> "menhir-parser"



let suffix s =
  let dot = String.rindex s '.' in
  String.sub s dot (String.length s - dot)


let languages_of_suffix = function
  | ".y"
  | ".l"
  | ".c" -> [C]
  | ".c++"
  | ".Y" | ".ypp" | ".yy"
  | ".L" | ".lpp" | ".ll"
  | ".C"
  | ".cc"
  | ".cp"
  | ".CPP"
  | ".cpp"
  | ".cxx" -> [Cxx]
  | ".as" -> [Aldor]
  | ".mll"
  | ".ml"
  | ".mlr"
  | ".mly"
  | ".mlypack" -> [OCaml]
  | s -> failwith ("unknown suffix: " ^ s)


let guess_languages decls =
  let langs =
    if List.exists (function Modules _ -> true | _ -> false) decls then
      (* the Modules variable is only used in OCaml libraries *)
      [OCaml]
    else if List.exists (function Domains _ -> true | _ -> false) decls then
      (* the Domains variable is only used in Aldor libraries *)
      [Aldor]
    else
      []
  in

  let sources =
    List.map (function Sources l -> l | _ -> []) decls
    |> List.flatten
  in

  let suffix_langs =
    List.map suffix sources
    |> List.map languages_of_suffix
    |> List.flatten
  in

  suffix_langs @ langs


let target action kind tag decls =
  let langs = List.sort compare (guess_languages decls) in
  { action; kind; tag; decls; langs; lang = List.hd langs; }


let targets = ref []

let add_target action kind tag decls =
  targets := target action kind tag decls :: !targets

let install = add_target Install
let build = add_target Build
let sections = List.map (fun () -> ())
