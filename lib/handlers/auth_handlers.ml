let logout req =
  let%lwt () = Dream.invalidate_session req in
  Dream.redirect req "/login"
;;

let login_get req = Dream.html (Auth_views.login_page req)

let login_post request =
  match%lwt Dream.form request with
  | `Ok fields ->
    (try
       let email = List.assoc "email" fields in
       let password = List.assoc "password" fields in
       Dream.sql request (fun db ->
         match%lwt Auth_db.get_user_by_email db email with
         | Some user ->
           let%lwt valid = Password.verify_password password user.password_hash in
           if valid
           then (
             let%lwt () =
               Dream.set_session_field request "user_id" (Int.to_string user.id)
             in
             Dream.redirect request "/")
           else Dream.html (Auth_views.login_page ~error:"Invalid credentials" request)
         | None -> Dream.html (Auth_views.login_page ~error:"User not found" request))
     with
     | Not_found ->
       Dream.html (Auth_views.login_page ~error:"Missing email or password" request))
  | _ -> Dream.html (Auth_views.login_page ~error:"Invalid form" request)
;;

let register_get req = Dream.html (Auth_views.register_page req)

let register_post request =
  match%lwt Dream.form request with
  | `Ok fields ->
    (try
       let email = List.assoc "email" fields in
       let nickname = List.assoc "nickname" fields in
       let password = List.assoc "password" fields in
       Dream.sql request (fun db ->
         match%lwt Auth_db.get_user_by_email db email with
         | Some _ ->
           Dream.html (Auth_views.register_page ~error:"Email already registered" request)
         | None ->
           let%lwt password_hash = Password.hash_password password in
           (match%lwt Auth_db.create_user db ~email ~password_hash ~nickname with
            | Ok _ -> Dream.redirect request "/login"
            | Error err ->
              let error_msg =
                Printf.sprintf "Registration failed: %s" (Caqti_error.show err)
              in
              Dream.log "Error creating user: %s" error_msg;
              Dream.html (Auth_views.register_page ~error:error_msg request)))
     with
     | Not_found ->
       Dream.html (Auth_views.register_page ~error:"Missing required fields" request))
  | _ -> Dream.html (Auth_views.register_page ~error:"Invalid form" request)
;;
