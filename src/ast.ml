open Sexplib.Conv

type language =
  | LaTeX
  | OCaml
  | Aldor
  | C
  | Cxx
  with sexp

let all_languages = [Aldor; C; Cxx; OCaml; LaTeX]

type builtin =
  | PHONY
  | DEFAULT
  | SUBDIRS
  with sexp

type word =
  | Builtin of builtin
  | String of string
  | Var of char
  | FCall of string * word list list
  with sexp

type kv =
  | Flag of string * string list
  with sexp

type defn =
  | Include of string

  | Name of string
  | Description of string list
  | Requires of language * string list
  | Sources of language * string list
  | Headers of language * string list
  | Flags of kv list
  | Version of string

  | FunCall of string * word list list
  | VarDefn of string * word list
  | Array of string * word list list
  | Object of string * kv list
  | Rule of word list * word list * word list list
  with sexp

type t = defn list with sexp

type target = {
  tree : t;
  languages : language list;
  main_language : language;
} with sexp


let builtin_of_string = function
  | "PHONY" -> PHONY
  | "DEFAULT" -> DEFAULT
  | "SUBDIRS" -> SUBDIRS
  | s -> failwith s

let language_of_string = function
  | "aldor"
  | "Aldor" -> Aldor
  | "c"
  | "C" -> C
  | "cxx"
  | "Cxx" -> Cxx
  | "ocaml"
  | "OCaml" -> OCaml
  | "latex"
  | "LaTeX" -> LaTeX
  | s -> failwith s
