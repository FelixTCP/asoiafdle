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
