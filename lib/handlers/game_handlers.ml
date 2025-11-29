let index req =
  let user_id = Dream.session_field req "user_id" in
  let csrf = Dream.csrf_token req in
  let target = Game.get_daily_character () in
  let today =
    Unix.time ()
    |> Unix.localtime
    |> fun tm ->
    Printf.sprintf
      "%04d-%02d-%02d"
      (tm.Unix.tm_year + 1900)
      (tm.Unix.tm_mon + 1)
      tm.Unix.tm_mday
  in
  match user_id with
  | Some id_str ->
    (match int_of_string_opt id_str with
     | Some id ->
       Dream.sql req (fun db ->
         let%lwt user_opt = Auth_db.get_user_by_id db id in
         (* Load today's game from database *)
         let%lwt game_opt = Db.get_today_game db ~user_id:id ~date:today in
         match game_opt with
         | Ok (Some (_character_name, _num_guesses, guess_names_opt, won, _date)) ->
           (* Game exists in DB - load it *)
           let guesses_list =
             match guess_names_opt with
             | Some json ->
               (try
                  let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
                  Yojson.Safe.from_string json |> [%of_yojson: string list]
                with
                | _ -> [])
             | None -> []
           in
           (* Reverse list so newest guess is at bottom *)
           let guesses_list_ordered = List.rev guesses_list in
           let guesses_html =
             List.map
               (fun name ->
                  match Game.find_character name with
                  | Some c ->
                    let result = Game.compare target c in
                    Game_views.guess_result c result
                  | None -> "")
               guesses_list_ordered
             |> String.concat ""
           in
           Dream.html
             (Game_views.index_page
                ?user:user_opt
                ~guesses:guesses_html
                ~csrf
                ~game_complete:won
                ())
         | _ ->
           (* No game yet today - fresh start *)
           Dream.html
             (Game_views.index_page
                ?user:user_opt
                ~guesses:""
                ~csrf
                ~game_complete:false
                ()))
     | None ->
       (* Invalid user ID - treat as guest *)
       Dream.html
         (Game_views.index_page ?user:None ~guesses:"" ~csrf ~game_complete:false ()))
  | None ->
    (* Guest user - use session-based state *)
    let guesses_json = Dream.session_field req "guesses" in
    let guesses_list =
      match guesses_json with
      | Some json ->
        (try
           let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
           Yojson.Safe.from_string json |> [%of_yojson: string list]
         with
         | _ -> [])
      | None -> []
    in
    (* Reverse list so newest guess is at bottom *)
    let guesses_list_ordered = List.rev guesses_list in
    let guesses_html =
      List.map
        (fun name ->
           match Game.find_character name with
           | Some c ->
             let result = Game.compare target c in
             Game_views.guess_result c result
           | None -> "")
        guesses_list_ordered
      |> String.concat ""
    in
    let won = Dream.session_field req "won" = Some "true" in
    Dream.html
      (Game_views.index_page ?user:None ~guesses:guesses_html ~csrf ~game_complete:won ())
;;

let guess req =
  match%lwt Dream.form req with
  | `Ok fields ->
    (try
       let guess_name = List.assoc "guess" fields in
       let target = Game.get_daily_character () in
       (* Get current guesses from session *)
       let guesses_json = Dream.session_field req "guesses" in
       let guesses =
         match guesses_json with
         | Some json ->
           (try
              let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
              Yojson.Safe.from_string json |> [%of_yojson: string list]
            with
            | _ -> [])
         | None -> []
       in
       (* Check if game is won, max guesses reached, or already guessed *)
       let won = Dream.session_field req "won" in
       if won = Some "true" || List.length guesses >= 6 || List.mem guess_name guesses
       then Dream.html ""
       else (
         match Game.find_character guess_name with
         | Some guessed_char ->
           let result = Game.compare target guessed_char in
           let new_guesses = guess_name :: guesses in
           let%lwt () =
             Dream.set_session_field
               req
               "guesses"
               (let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
                [%yojson_of: string list] new_guesses |> Yojson.Safe.to_string)
           in
           (* Check if won *)
           let is_win =
             String.lowercase_ascii guess_name = String.lowercase_ascii target.name
           in
           let num_guesses = List.length new_guesses in
           (* Save game state for logged-in users on EVERY guess *)
           let user_id = Dream.session_field req "user_id" in
           let%lwt () =
             match user_id with
             | None -> Lwt.return_unit
             | Some id_str ->
               (match int_of_string_opt id_str with
                | None -> Lwt.return_unit
                | Some uid ->
                  Dream.sql req (fun db ->
                    let today =
                      Unix.time ()
                      |> Unix.localtime
                      |> fun tm ->
                      Printf.sprintf
                        "%04d-%02d-%02d"
                        (tm.Unix.tm_year + 1900)
                        (tm.Unix.tm_mon + 1)
                        tm.Unix.tm_mday
                    in
                    let guess_names_json =
                      let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
                      [%yojson_of: string list] new_guesses |> Yojson.Safe.to_string
                    in
                    (* Save game state on every guess - this prevents cheating by logout/login *)
                    let%lwt save_result =
                      Db.save_game
                        db
                        ~user_id:uid
                        ~character_name:target.name
                        ~guesses:num_guesses
                        ~guess_names:guess_names_json
                        ~date:today
                        ~won:is_win
                    in
                    match save_result with
                    | Ok () ->
                      if is_win
                      then Metrics_db.increment_counter db "total_games_won"
                      else Lwt.return_unit
                    | Error err ->
                      Dream.log "Error saving game: %s" (Caqti_error.show err);
                      Lwt.return_unit))
           in
           if is_win
           then (
             let%lwt () = Dream.set_session_field req "won" "true" in
             Dream.html
               (Printf.sprintf
                  {|
                  %s
                  <div class='bg-green-900 border-2 border-green-500 rounded-lg p-4 mt-4 text-center'>
                    <h3 class='text-2xl font-bold text-green-400 mb-2'>🎉 Congratulations! 🎉</h3>
                    <p class='text-lg'>You found <strong>%s</strong> in %d guesses!</p>
                    <p class='text-sm mt-2 text-gray-300'>Come back tomorrow for a new character!</p>
                  </div>
                |}
                  (Game_views.guess_result guessed_char result)
                  target.name
                  num_guesses))
           else if num_guesses >= 6
           then
             Dream.html
               (Printf.sprintf
                  {|
                  %s
                  <div class='bg-red-900 border-2 border-red-500 rounded-lg p-4 mt-4 text-center'>
                    <h3 class='text-2xl font-bold text-red-400 mb-2'>Game Over!</h3>
                    <p class='text-lg'>The character was <strong>%s</strong></p>
                    <p class='text-sm mt-2 text-gray-300'>Better luck tomorrow!</p>
                  </div>
                |}
                  (Game_views.guess_result guessed_char result)
                  target.name)
           else Dream.html (Game_views.guess_result guessed_char result)
         | None ->
           (* Character not in list - silently ignore *)
           Dream.html "")
     with
     | Not_found -> Dream.html "")
  | _ -> Dream.html ""
;;
