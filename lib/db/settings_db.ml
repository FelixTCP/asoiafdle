let update_nickname_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.string Caqti_type.int ->. Caqti_type.unit)
  @@ "UPDATE users SET nickname = ? WHERE id = ?"
;;

let update_nickname (module Db : Caqti_lwt.CONNECTION) ~user_id ~nickname =
  Db.exec update_nickname_query (nickname, user_id)
;;

let update_email_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.string Caqti_type.int ->. Caqti_type.unit)
  @@ "UPDATE users SET email = ? WHERE id = ?"
;;

let update_email (module Db : Caqti_lwt.CONNECTION) ~user_id ~email =
  Db.exec update_email_query (email, user_id)
;;

let update_password_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.string Caqti_type.int ->. Caqti_type.unit)
  @@ "UPDATE users SET password_hash = ? WHERE id = ?"
;;

let update_password (module Db : Caqti_lwt.CONNECTION) ~user_id ~password_hash =
  Db.exec update_password_query (password_hash, user_id)
;;

(* Account deletion - fully delete per user request (allows email re-use) *)
let delete_account_query =
  let open Caqti_request.Infix in
  (Caqti_type.int ->. Caqti_type.unit) @@ "DELETE FROM users WHERE id = ?"
;;

let increment_deletion_count_query =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->. Caqti_type.unit)
  @@ "UPDATE app_metadata SET value = value + 1, updated_at = CURRENT_TIMESTAMP WHERE \
      key = 'total_deletions'"
;;

let delete_account (module Db : Caqti_lwt.CONNECTION) ~user_id =
  (* Increment deletion counter before deleting user *)
  let%lwt count_result = Db.exec increment_deletion_count_query () in
  match count_result with
  | Error err ->
    (* Log but don't fail deletion if counter update fails *)
    let () =
      Dream.log "Warning: Failed to increment deletion counter: %s" (Caqti_error.show err)
    in
    Db.exec delete_account_query user_id
  | Ok () ->
    (* SQLite will cascade delete due to foreign keys *)
    (* This deletes from users, which triggers cascade delete on games and friends *)
    Db.exec delete_account_query user_id
;;

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
