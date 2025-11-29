let settings_get req =
  let user_id = Dream.session_field req "user_id" in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some id ->
       Dream.sql req (fun db ->
         let%lwt user_opt = Auth_db.get_user_by_id db id in
         Dream.html (Settings_views.settings_page ?user:user_opt req))
     | None -> Dream.redirect req "/login")
  | None -> Dream.redirect req "/login"
;;

let update_settings_post req =
  let user_id = Dream.session_field req "user_id" in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some id ->
       (match%lwt Dream.form req with
        | `Ok fields ->
          (try
             let current_password = List.assoc "current_password" fields in
             let new_email = List.assoc_opt "email" fields in
             let new_nickname = List.assoc_opt "nickname" fields in
             let new_password = List.assoc_opt "new_password" fields in
             let confirm_password = List.assoc_opt "confirm_password" fields in
             Dream.sql req (fun db ->
               match%lwt Auth_db.get_user_by_id db id with
               | Some user ->
                 let%lwt valid =
                   Password.verify_password current_password user.password_hash
                 in
                 if not valid
                 then (
                   let%lwt user_opt = Auth_db.get_user_by_id db id in
                   Dream.html
                     (Settings_views.settings_page
                        ?user:user_opt
                        ~error:"Incorrect current password"
                        req))
                 else (
                   (* Check if password fields are valid if provided *)
                   let password_error =
                     match new_password, confirm_password with
                     | Some np, Some cp when np <> "" ->
                       if np <> cp then Some "New passwords do not match" else None
                     | Some np, None when np <> "" ->
                       Some "Please confirm your new password"
                     | _ -> None
                   in
                   match password_error with
                   | Some err ->
                     let%lwt user_opt = Auth_db.get_user_by_id db id in
                     Dream.html
                       (Settings_views.settings_page ?user:user_opt ~error:err req)
                   | None ->
                     (* Process updates *)
                     let updates = ref [] in
                     (* Update email if provided *)
                     let%lwt () =
                       match new_email with
                       | Some email when email <> "" ->
                         (match%lwt Settings_db.update_email db ~user_id:id ~email with
                          | Ok () ->
                            updates := "email" :: !updates;
                            Lwt.return_unit
                          | Error _err -> Lwt.return_unit)
                       | _ -> Lwt.return_unit
                     in
                     (* Update nickname if provided *)
                     let%lwt () =
                       match new_nickname with
                       | Some nickname when nickname <> "" ->
                         (match%lwt
                            Settings_db.update_nickname db ~user_id:id ~nickname
                          with
                          | Ok () ->
                            updates := "nickname" :: !updates;
                            Lwt.return_unit
                          | Error _err -> Lwt.return_unit)
                       | _ -> Lwt.return_unit
                     in
                     (* Update password if provided *)
                     let%lwt () =
                       match new_password with
                       | Some password when password <> "" ->
                         let%lwt password_hash = Password.hash_password password in
                         (match%lwt
                            Settings_db.update_password db ~user_id:id ~password_hash
                          with
                          | Ok () ->
                            updates := "password" :: !updates;
                            Lwt.return_unit
                          | Error _err -> Lwt.return_unit)
                       | _ -> Lwt.return_unit
                     in
                     (* Show success message *)
                     let%lwt user_opt = Auth_db.get_user_by_id db id in
                     if List.length !updates > 0
                     then
                       Dream.html
                         (Settings_views.settings_page
                            ?user:user_opt
                            ~success:
                              (Printf.sprintf
                                 "Successfully updated: %s"
                                 (String.concat ", " (List.rev !updates)))
                            req)
                     else
                       Dream.html
                         (Settings_views.settings_page
                            ?user:user_opt
                            ~error:"No changes were made"
                            req))
               | None -> Dream.redirect req "/login")
           with
           | Not_found ->
             Dream.sql req (fun db ->
               let%lwt user_opt = Auth_db.get_user_by_id db id in
               Dream.html
                 (Settings_views.settings_page
                    ?user:user_opt
                    ~error:"Current password is required"
                    req)))
        | _ ->
          Dream.sql req (fun db ->
            let%lwt user_opt = Auth_db.get_user_by_id db id in
            Dream.html
              (Settings_views.settings_page ?user:user_opt ~error:"Invalid form" req)))
     | None -> Dream.redirect req "/login")
  | None -> Dream.redirect req "/login"
;;

let delete_account_post req =
  let user_id = Dream.session_field req "user_id" in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some id ->
       (match%lwt Dream.form req with
        | `Ok fields ->
          (try
             let password = List.assoc "password" fields in
             let confirm = List.assoc "confirm_deletion" fields in
             (* Require exact confirmation text *)
             if confirm <> "DELETE"
             then
               Dream.sql req (fun db ->
                 let%lwt user_opt = Auth_db.get_user_by_id db id in
                 Dream.html
                   (Settings_views.settings_page
                      ?user:user_opt
                      ~error:"Please type DELETE to confirm account deletion"
                      req))
             else
               Dream.sql req (fun db ->
                 match%lwt Auth_db.get_user_by_id db id with
                 | Some user ->
                   let%lwt valid = Password.verify_password password user.password_hash in
                   if not valid
                   then
                     Dream.html
                       (Settings_views.settings_page
                          ?user:(Some user)
                          ~error:"Incorrect password"
                          req)
                   else (
                     (* Delete account *)
                     match%lwt
                       Settings_db.delete_account db ~user_id:id
                     with
                     | Ok () ->
                       (* Invalidate session *)
                       let%lwt () = Dream.invalidate_session req in
                       (* Redirect to register with success message *)
                       Dream.html
                         "<html><body><h2>Account Deleted</h2><p>Your account has been \
                          successfully deleted. <a href='/register'>Register \
                          again</a></p></body></html>"
                     | Error err ->
                       Dream.log "Error deleting account: %s" (Caqti_error.show err);
                       Dream.html
                         (Settings_views.settings_page
                            ?user:(Some user)
                            ~error:"Failed to delete account. Please try again later."
                            req))
                 | None -> Dream.redirect req "/login")
           with
           | Not_found ->
             Dream.sql req (fun db ->
               let%lwt user_opt = Auth_db.get_user_by_id db id in
               Dream.html
                 (Settings_views.settings_page
                    ?user:user_opt
                    ~error:"Password and confirmation required"
                    req)))
        | _ ->
          Dream.sql req (fun db ->
            let%lwt user_opt = Auth_db.get_user_by_id db id in
            Dream.html
              (Settings_views.settings_page ?user:user_opt ~error:"Invalid form" req)))
     | None -> Dream.redirect req "/login")
  | None -> Dream.redirect req "/login"
;;
