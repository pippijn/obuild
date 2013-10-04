let stack = Stack.create ()
let token : (Lexing.lexbuf -> Parser.token) ref = ref (fun lexbuf -> failwith "no function")

let push m =
  Stack.push !token stack;
  token := m

let pop () =
  token := Stack.pop stack
