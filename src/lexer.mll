{
  open Parser

  exception No_parse

  let error lexbuf msg =
    let p = Lexing.lexeme_start_p lexbuf in
    failwith (Printf.sprintf
      "%d:%d: %s"
      p.Lexing.pos_lnum
      (p.Lexing.pos_cnum - p.Lexing.pos_bol)
      msg
    )
}

let d = ['0'-'9']
let uc = ['A'-'Z']
let lc = ['a'-'z']
let l = (d|uc|lc|'-'|'_'|'.'|'/')

let ws = [' ''\t']
let nws = [^' ''\t''\n''('')''$'',']

let name = (uc|lc) l*

let svar = ['^''<''@''+']


rule in_var = parse
| nws+ as s			{ WORD s }

| [' ''\t']			{ in_var lexbuf }

| ","				{ COMMA }
| "$"(svar as s)		{ VAR s }
| "$("				{ Feedback.(push in_var); VAR_OPEN }
| ")"				{ Feedback.pop (); VAR_CLOSE }

| _ as c			{ error lexbuf (Printf.sprintf "in var: '%s'" (Char.escaped c)) }

| eof				{ EOF }


and in_key = parse
| name as s			{ WORD s }

| "|"				{ Feedback.pop (); KEY_CLOSE }

| _ as c			{ error lexbuf (Printf.sprintf "in key: '%s'" (Char.escaped c)) }

| eof				{ EOF }


and in_definition = parse
| "\n" ws* '#' [^'\n']*		{ in_definition lexbuf }

| "\n      "			{ Lexing.new_line lexbuf; INDENT 3 }
| "\n    "			{ Lexing.new_line lexbuf; INDENT 2 }
| "\n  "			{ Lexing.new_line lexbuf; INDENT 1 }
| '\n'				{ Lexing.new_line lexbuf; Feedback.pop (); EOL }

| ","				{ COMMA }
| "="				{ EQUAL }
| "$"(svar as s)		{ VAR s }
| "$("				{ Feedback.(push in_var); VAR_OPEN }
| "$|"				{ Feedback.(push in_key); KEY_OPEN }
| "("				{ LPAREN }
| ")"				{ RPAREN }

| "$\"" [^'"']* '"' as s	{ WORD s }

| [' ''\t']			{ in_definition lexbuf }

| nws+ as s			{ WORD s }

| _ as c			{ error lexbuf (Printf.sprintf "in definition: '%s'" (Char.escaped c)) }

| eof				{ EOF }


and token = parse
| ".SYSTEM:"			{ raise No_parse }
| '#' [^'\n']*			{ token lexbuf }
| "\n" ws* '#' [^'\n']*		{ token lexbuf }

| "include" ws+	(nws+ as s)	{ KW_include s }

| "Name"			{ KW_Name }
| "Description"			{ KW_Description }
| (name as l) "-Requires[]"	{ KW_Requires (Ast.language_of_string l) }
| (name as l) "-Sources[]"	{ KW_Sources (Ast.language_of_string l) }
| (name as l) "-Headers[]"	{ KW_Headers (Ast.language_of_string l) }
| "Flags."			{ KW_Flags }

| (name as s) "[]"		{ ARRAY s }
| (name as s) "."		{ OBJECT s }
| name as s			{ NAME s }

| '.' (uc+ as s)		{ BUILTIN s }
| '\n'				{ Lexing.new_line lexbuf; EOL }

| '/' l* as s			{ NAME s }
| '%' l* as s			{ NAME s }
| '.' l* as s			{ NAME s }

| ","				{ COMMA }
| ":"				{ Feedback.(push in_definition); COLON }
| "="				{ Feedback.(push in_definition); EQUAL }
| "+="				{ Feedback.(push in_definition); ADDEQUAL }
| "$"(svar as s)		{ VAR s }
| "$("				{ Feedback.(push in_var); VAR_OPEN }
| "("				{ LPAREN }
| ")"				{ RPAREN }

| "$\"" [^'"']* '"' as s	{ WORD s }

| [' ''\t']			{ token lexbuf }

| _ as c			{ error lexbuf (Printf.sprintf "invalid character: '%s'" (Char.escaped c)) }

| eof				{ EOF }
