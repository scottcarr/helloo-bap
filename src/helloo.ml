open Core_kernel.Std
open Bap.Std
open Bap_primus.Std

(* let counter = object
 *     inherit [int * int] Term.visitor
 *     method! enter_term _ _ (jmps, total) = jmps,total+1
 *     method! enter_jmp _ (jmps,total) = jmps+1,total
 * end
 *
 * let main proj =
 *     let jmps,total = counter#run (Project.program proj) (0,0) in
 *     printf "ratio = %d/%d = %g\n" jmps total (float jmps /. float total) *)

let counter = object
    inherit [int] Term.visitor
    method! enter_sub _ (total) = total+1
end

let main proj =
  (* let total = counter#run (Project.program proj) (0) in *)
  (* printf "# subs: %d\n" total *)

let () = Project.register_pass' main

(*let env = Primus.Env.Make(Machine)*)

