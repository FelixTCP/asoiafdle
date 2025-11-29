let leaderboard req =
  let user_id = Dream.session_field req "user_id" in
  let csrf = Dream.csrf_token req in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some id ->
       Dream.sql req (fun db ->
         let%lwt user_opt = Auth_db.get_user_by_id db id in
         let%lwt global = Leaderboard_db.get_global_leaderboard db in
         let%lwt friends = Leaderboard_db.get_friends_leaderboard db id in
         match global, friends with
         | Ok g, Ok f ->
           Dream.html
             (Leaderboard_views.leaderboard_page
                ?user:user_opt
                ~global:g
                ~friends:f
                ~csrf
                ())
         | _ ->
           Dream.html
             (Leaderboard_views.leaderboard_page
                ?user:user_opt
                ~global:[]
                ~friends:[]
                ~csrf
                ()))
     | None ->
       Dream.sql req (fun db ->
         let%lwt global = Leaderboard_db.get_global_leaderboard db in
         match global with
         | Ok g ->
           Dream.html
             (Leaderboard_views.leaderboard_page
                ?user:None
                ~global:g
                ~friends:[]
                ~csrf
                ())
         | _ ->
           Dream.html
             (Leaderboard_views.leaderboard_page
                ?user:None
                ~global:[]
                ~friends:[]
                ~csrf
                ())))
  | None ->
    Dream.sql req (fun db ->
      let%lwt global = Leaderboard_db.get_global_leaderboard db in
      match global with
      | Ok g ->
        Dream.html
          (Leaderboard_views.leaderboard_page ?user:None ~global:g ~friends:[] ~csrf ())
      | _ ->
        Dream.html
          (Leaderboard_views.leaderboard_page ?user:None ~global:[] ~friends:[] ~csrf ()))
;;

let add_friend req =
  let user_id = Dream.session_field req "user_id" in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some user_id ->
       (match%lwt Dream.form req with
        | `Ok fields ->
          (try
             let friend_code = List.assoc "friend_code" fields in
             Dream.sql req (fun db ->
               match%lwt Auth_db.get_user_by_friend_code db friend_code with
               | Some friend ->
                 if friend.Models.id = user_id
                 then
                   Dream.html
                     "<div class='text-yellow-500'>You cannot add yourself as a \
                      friend!</div>"
                 else (
                   let%lwt is_friend =
                     Leaderboard_db.is_already_friend db user_id friend.Models.id
                   in
                   if is_friend
                   then
                     Dream.html
                       (Printf.sprintf
                          "<div class='text-yellow-500'>%s is already your friend!</div>"
                          friend.Models.nickname)
                   else (
                     match%lwt Leaderboard_db.add_friend db user_id friend.Models.id with
                     | Ok () ->
                       Dream.html
                         (Printf.sprintf
                            "<div class='text-green-500'>Successfully added %s as a \
                             friend!</div>"
                            friend.Models.nickname)
                     | Error err ->
                       Dream.log "Error adding friend: %s" (Caqti_error.show err);
                       Dream.html
                         "<div class='text-red-500'>Failed to add friend. Please try \
                          again later.</div>"))
               | None ->
                 Dream.html "<div class='text-red-500'>Friend code not found</div>")
           with
           | Not_found ->
             Dream.html "<div class='text-red-500'>Friend code required</div>")
        | _ -> Dream.html "<div class='text-red-500'>Invalid form</div>")
     | None -> Dream.html "<div class='text-red-500'>Invalid session</div>")
  | None -> Dream.html "<div class='text-yellow-500'>Please login to add friends</div>"
;;
