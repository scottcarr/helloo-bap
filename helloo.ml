open Core_kernel.Std
open Bap.Std
open Bap_primus.Std
open Monads.Std
open Format

(* let counter = object
 *     inherit [int * int] Term.visitor
 *     method! enter_term _ _ (jmps, total) = jmps,total+1
 *     method! enter_jmp _ (jmps,total) = jmps+1,total
 * end
 *
 * let main proj =
 *     let jmps,total = counter#run (Project.program proj) (0,0) in
 *     printf "ratio = %d/%d = %g\n" jmps total (float jmps /. float total)
 *
 * let counter = object
 *     inherit [int] Term.visitor
 *     method! enter_sub _ (total) = total+1
 * end
 *
 * let main proj =
 *   let total = counter#run (Project.program proj) (0) in
 *   printf "# subs: %d\n" total
 *
 * let () = Project.register_pass' main *)


(* start copied from plugins/run/run_main.ml*)
(* apparently I need to make a machine monad? and this makes the identity monad? *)
module Machine = struct
  type 'a m = 'a
  include Primus.Machine.Make(Monad.Ident)
end
open Machine.Syntax (* I don't know what Machine.Syntax does *)

(* I guess I need to instantiate these things *)
module Main = Primus.Machine.Main(Machine)
module Interpreter = Primus.Interpreter.Make(Machine)
module Linker = Primus.Linker.Make(Machine)
module Env = Primus.Env.Make(Machine)
(* module Lisp = Primus.Lisp.Make(Machine) *) (* I don't want to use Lisp *)

(* copied from run_main.mli *)
let string_of_name = function
  | `symbol s -> s
  | `tid t -> Tid.to_string t
  | `addr x -> Addr.string_of_value x

let pp_id = Monad.State.Multi.Id.pp

let exec x =
  Machine.current () >>= fun cid ->
  printf "Fork %a: starting from the %s entry point\n"
    pp_id cid (string_of_name x);
  printf "Fork starting\n";
  Machine.catch (Linker.exec x)
    (fun exn ->
       printf "execution from %s terminated with: %s \n"
         (string_of_name x)
         (Primus.Exn.to_string exn);
       Machine.return ())

let main proj =
  exec (`symbol "_start") |> Main.run proj |> function
  | (Primus.Normal,proj)
  | (Primus.Exn Primus.Interpreter.Halt,proj) ->
    printf "Ok, we've terminated normally.\n"
  | (Primus.Exn exn,proj) ->
    printf "program terminated by a signal: %s\n" (Primus.Exn.to_string exn)

let () = Project.register_pass' main


