(* elpi: embedded lambda prolog interpreter                                  *)
(* license: GNU Lesser General Public License Version 2.1 or later           *)
(* ------------------------------------------------------------------------- *)

open Elpi_util
open Elpi_data

type flags = {
  defined_variables : StrSet.t;
  allow_untyped_builtin : bool;
  print_passes : bool; (* debug *)
}
val default_flags : flags

type program
type query

(* Flags are threaded *)
val program_of_ast : flags:flags -> Elpi_ast.Program.t -> program
val query_of_ast : program -> Elpi_ast.Goal.t -> query
val query_of_term :
  program -> (depth:int -> State.t -> State.t * (Loc.t * term)) -> query

val pp_query : (depth:int -> Format.formatter -> term -> unit) -> Format.formatter -> query -> unit

val executable_of_query : query -> Elpi_data.executable

val term_of_ast : depth:int -> Loc.t * Elpi_ast.Term.t -> term

type quotation = depth:int -> State.t -> Loc.t -> string -> State.t * term
val set_default_quotation : quotation -> unit
val register_named_quotation : name:string -> quotation -> unit

val lp : quotation

val is_Arg : State.t -> term -> bool
val get_Args : State.t -> term StrMap.t
val mk_Arg : 
  State.t -> name:string -> args:term list ->
    State.t * term

(* Quotes the program and the query, see elpi_quoted_syntax.elpi *)
val quote_syntax : query -> term list * term

(* false means a type error was found *)
val static_check : Elpi_ast.Program.t -> (* header *)
  ?exec:(?max_steps:int -> Elpi_data.executable -> Elpi_data.outcome) ->
  ?checker:Elpi_ast.Program.t ->
  ?flags:flags ->
  query -> bool

val while_compiling : bool State.component
