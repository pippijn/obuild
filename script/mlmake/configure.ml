#!/usr/bin/ocaml

#use "mlmake/target.ml"
#use "makefiles.ml"


let print_names =
  List.iter (function
    | Name s ->
        print_endline s;
    | _ ->
        ()
  )


let () =
  let targets = !targets in

  if targets = [] then
    failwith "no targets found";

  match Sys.argv with
  | [|_; "-ocaml-libs"|] ->
      List.iter (function
        | { action = Install; kind = (Syntax | Library | Package); lang = OCaml; decls } ->
            print_names decls
        | _ ->
            ()
      ) targets

  | [|_; "-ocaml-progs"|] ->
      List.iter (function
        | { action = Install; kind = Program; lang = OCaml; decls } ->
            print_names decls
        | _ ->
            ()
      ) targets

  | [|_; "-c-libs"|] ->
      List.iter (function
        | { action = Install; kind = Library; lang = (C | Cxx); decls } ->
            print_names decls
        | _ ->
            ()
      ) targets

  | [|_; "-c-progs"|] ->
      List.iter (function
        | { action = Install; kind = Program; lang = (C | Cxx); decls } ->
            print_names decls
        | _ ->
            ()
      ) targets

  | _ ->
      failwith "invalid argument"