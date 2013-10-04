%{
  open Ast
%}

%token EOF
%token EOL
%token LPAREN
%token RPAREN
%token COMMA
%token EQUAL
%token ADDEQUAL
%token COLON
%token VAR_OPEN
%token VAR_CLOSE
%token KEY_OPEN
%token KEY_CLOSE

%token KW_Name
%token KW_Description
%token KW_Flags
%token<Ast.language> KW_Requires
%token<Ast.language> KW_Sources
%token<Ast.language> KW_Headers
%token<string> KW_include

%token<int> INDENT
%token<string> ARRAY
%token<string> OBJECT
%token<string> BUILTIN
%token<string> NAME
%token<string> WORD
%token<char> VAR

%start<Ast.t> parse

%%

parse:
	| loption(definition_list) EOF			{ List.rev $1 }


definition_list:
	| definition					{ $1 }
	| definition_list definition			{ $2 @ $1 }


definition:
	| KW_include EOL				{ [Include $1] }

	| KW_Name EQUAL name EOL			{ [Name $3] }
	| KW_Description EQUAL plus(name) EOL		{ [Description $3] }
	| KW_Requires eq_op array(name) EOL		{ [Requires ($1, $3)] }
	| KW_Sources eq_op array(name) EOL		{ [Sources ($1, $3)] }
	| KW_Headers eq_op array(name) EOL		{ [Headers ($1, $3)] }
	| KW_Flags ADDEQUAL array(key_value) EOL	{ [Flags $3] }

	| NAME eq_op plus(word) EOL			{ [VarDefn ($1, $3)] }
	| NAME LPAREN loption(args) RPAREN EOL		{ [FunCall ($1, $3)] }
	| ARRAY eq_op array(plus(word)) EOL		{ [Array ($1, $3)] }
	| OBJECT eq_op array(key_value) EOL		{ [Object ($1, $3)] }
	| rule EOL					{ [$1] }
	| EOL						{ [] }

eq_op:
	| EQUAL						{ }
	| ADDEQUAL					{ }

rule:
	| plus(word) COLON loption(plus(word)) loption(array(rule_line))
							{ Rule ($1, $3, $4) }

rule_line:
	| plus(word)					{ $1 }
	| WORD LPAREN loption(args) RPAREN		{ [FCall ($1, $3)] }

word:
	| BUILTIN					{ Builtin (builtin_of_string $1) }
	| name						{ String $1 }
	| fcall						{ $1 }


name:
	| NAME						{ $1 }
	| WORD						{ $1 }

fcall:
	| VAR						{ Var $1 }
	| VAR_OPEN fcall_contents VAR_CLOSE		{ $2 }


fcall_contents:
	| name loption(args)				{ FCall ($1, $2) }

args:
	| args_						{ List.rev $1 }

args_:
	| plus(word)					{ [$1] }
	| args_ COMMA plus(word)			{ $3 :: $1 }


key_value:
	| key EQUAL plus(name)				{ Flag ($1, $3) }

key:
	| KEY_OPEN WORD KEY_CLOSE			{ $2 }


/* List */
array(w):
	| array_(w)					{ List.rev $1 }

array_(w):
	| array_line(w)					{ [$1] }
	| array_(w) array_line(w)			{ $2 :: $1 }

array_line(w):
	| INDENT w					{ $2 }


plus(elt):
	| plus_(elt)					{ List.rev $1 }

plus_(elt):
	| elt						{ [$1] }
	| plus_(elt) elt				{ $2 :: $1 }

