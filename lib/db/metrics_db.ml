(* Database operations for metrics *)

(* Generic counter increment *)
let increment_counter_query =
  let open Caqti_request.Infix in
  (Caqti_type.string ->. Caqti_type.unit)
  @@ "UPDATE app_metadata SET value = value + 1, updated_at = CURRENT_TIMESTAMP WHERE \
      key = ?"
;;

let increment_counter (module Db : Caqti_lwt.CONNECTION) key =
  let%lwt result = Db.exec increment_counter_query key in
  match result with
  | Ok () -> Lwt.return_unit
  | Error err ->
    Dream.log "Warning: Failed to increment counter %s: %s" key (Caqti_error.show err);
    Lwt.return_unit
;;

(* Get counter value *)
let get_counter_query =
  let open Caqti_request.Infix in
  (Caqti_type.string ->? Caqti_type.int) @@ "SELECT value FROM app_metadata WHERE key = ?"
;;

let get_counter (module Db : Caqti_lwt.CONNECTION) key = Db.find_opt get_counter_query key
