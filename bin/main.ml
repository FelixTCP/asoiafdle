open Asoiafdle

let () =
  let db_url =
    Sys.getenv_opt "DATABASE_URL" |> Option.value ~default:"sqlite3:asoiafdle.db"
  in
  let secret =
    Sys.getenv_opt "SESSION_SECRET"
    |> Option.value ~default:"change_me_in_production_please"
  in
  Lwt_main.run (Db.init_db db_url);
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.set_secret secret
  @@ Dream.sql_pool db_url
  @@ Dream.cookie_sessions ~lifetime:1800.0
  @@ Dream.router
       [ Dream.get "/" Game_handlers.index
       ; Dream.post "/guess" Game_handlers.guess
       ; Dream.get "/login" Auth_handlers.login_get
       ; Dream.post "/login" Auth_handlers.login_post
       ; Dream.get "/register" Auth_handlers.register_get
       ; Dream.post "/register" Auth_handlers.register_post
       ; Dream.post "/logout" Auth_handlers.logout
       ; Dream.get "/leaderboard" Leaderboard_handlers.leaderboard
       ; Dream.post "/add-friend" Leaderboard_handlers.add_friend
       ; Dream.get "/settings" Settings_handlers.settings_get
       ; Dream.post "/settings/update" Settings_handlers.update_settings_post
       ; Dream.get "/static/**" (Dream.static "./static")
       ]
;;
