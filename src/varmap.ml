let rex =
  let open Re in
  [
    char '$';
    opt (group (char '@'));
    opt (group (char '?'));
    group
      (alt
         [
           seq
             [
               alt [ char '_'; rg 'a' 'z' ];
               rep
                 (alt
                    [ char '_'; char '\''; rg 'a' 'z'; rg 'A' 'Z'; rg '0' '9' ]);
             ];
           seq [ char '{'; rep (diff any (char '}')); char '}' ];
         ]);
  ]
  |> seq |> compile

type var = { varname : string; option : bool; list : bool }

(* Split the query into text and variable name parts using Re.split_full.
 * eg. "select id from employees where name = $name and salary > $salary"
 * would become a structure equivalent to:
 * ["select id from employees where name = "; "$name"; " and salary > ";
 * "$salary"].
 * Actually it's a wee bit more complicated than that ...
 *)
let split query =
  let f = function
    | `Text text -> `Text text
    | `Delim subs ->
        `Var
          Re.Group.
            { varname = get subs 3; list = test subs 1; option = test subs 2 }
  in
  List.map f (Re.split_full rex query)

type varmap = (int, var) Hashtbl.t

(* This is the compile time processing *)
let process_compile_query ~query : string * varmap =
  let split = split query in
  let varmap = Hashtbl.create 8 in
  let next =
    let i = ref 0 in
    fun () ->
      incr i;
      !i
  in
  let query =
    String.concat ""
      (List.map
         (function
           | `Text text -> text
           | `Var { varname; list; option } ->
               let i = next () in
               Hashtbl.add varmap i { varname; list; option };
               if list then Printf.sprintf "($%d)" i else Printf.sprintf "$%d" i)
         split)
  in
  (query, varmap)

(* Process a runtime query, this differs in treatment of lists and the fact it
  returns an expression? *)
let process_query split params =
  let i = ref 0 in
  let j = ref 0 in
  String.concat ""
    (List.map
       (function
         | `Text text -> text
         | `Var { list = false; _ } ->
             (* non-list item *)
             incr i;
             (* next parameter *)
             incr j;
             (* next placeholder number *)
             "$" ^ string_of_int j.contents
         | `Var { list = true; _ } ->
             (* list item *)
             let param = List.nth params i.contents in
             incr i;
             (* next parameter *)
             "("
             ^ String.concat ","
                 (List.map
                    (fun _ ->
                      incr j;
                      (* next placeholder number *)
                      "$" ^ string_of_int j.contents)
                    param)
             ^ ")")
       split)
