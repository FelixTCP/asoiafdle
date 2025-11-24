let get_user_by_friend_code_query =
  let open Caqti_request.Infix in
  (Caqti_type.string
   ->? Caqti_type.t6
         Caqti_type.int
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string)
  @@ "SELECT id, email, password_hash, nickname, friend_code, created_at FROM users \
      WHERE friend_code = ?"
;;

let get_user_by_friend_code (module Db : Caqti_lwt.CONNECTION) (code : string) =
  Db.find_opt get_user_by_friend_code_query code
  |> Lwt.map (function
    | Ok (Some (id, email, password_hash, nickname, friend_code, created_at)) ->
      Some { Models.id; email; password_hash; nickname; friend_code; created_at }
    | _ -> None)
;;

let rec generate_unique_friend_code db =
  let generate_segment () = String.init 4 (fun _ -> Char.chr (65 + Random.int 26)) in
  let code = Printf.sprintf "%s-%s" (generate_segment ()) (generate_segment ()) in
  match%lwt get_user_by_friend_code db code with
  | Some _ -> generate_unique_friend_code db (* Code exists, try again *)
  | None -> Lwt.return code
;;

let create_user_query =
  let open Caqti_request.Infix in
  (Caqti_type.t4 Caqti_type.string Caqti_type.string Caqti_type.string Caqti_type.string
   ->. Caqti_type.unit)
  @@ "INSERT INTO users (email, password_hash, nickname, friend_code) VALUES (?, ?, ?, ?)"
;;

let create_user (module Db : Caqti_lwt.CONNECTION) ~email ~password_hash ~nickname =
  let%lwt friend_code = generate_unique_friend_code (module Db) in
  Db.exec create_user_query (email, password_hash, nickname, friend_code)
;;

let get_user_by_email_query =
  let open Caqti_request.Infix in
  (Caqti_type.string
   ->? Caqti_type.t6
         Caqti_type.int
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string)
  @@ "SELECT id, email, password_hash, nickname, friend_code, created_at FROM users \
      WHERE email = ?"
;;

let get_user_by_email (module Db : Caqti_lwt.CONNECTION) (email : string) =
  Db.find_opt get_user_by_email_query email
  |> Lwt.map (function
    | Ok (Some (id, email, password_hash, nickname, friend_code, created_at)) ->
      Some { Models.id; email; password_hash; nickname; friend_code; created_at }
    | _ -> None)
;;

let get_user_by_id_query =
  let open Caqti_request.Infix in
  (Caqti_type.int
   ->? Caqti_type.t6
         Caqti_type.int
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string
         Caqti_type.string)
  @@ "SELECT id, email, password_hash, nickname, friend_code, created_at FROM users \
      WHERE id = ?"
;;

let get_user_by_id (module Db : Caqti_lwt.CONNECTION) (id : int) =
  Db.find_opt get_user_by_id_query id
  |> Lwt.map (function
    | Ok (Some (id, email, password_hash, nickname, friend_code, created_at)) ->
      Some { Models.id; email; password_hash; nickname; friend_code; created_at }
    | _ -> None)
;;
