open Asoiafdle

let () =
  (* Load and validate configuration *)
  let config = Config.load_config () in
  Config.print_startup_info config;
  (* Initialize database *)
  Lwt_main.run (Db.init_db config.db_url);
  (* Start web server *)
  Dream.run ~interface:"0.0.0.0" ~port:8080
  @@ Dream.logger
  @@ Dream.set_secret config.session_secret
  @@ Dream.sql_pool config.db_url
  @@ Dream.cookie_sessions ~lifetime:3600.0 (* 60 minutes *)
  @@ Metrics.track_request
  @@ Cors.create ~allowed_origin:"https://asoiafdle.duckdns.org"
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
       ; Dream.post "/settings/delete" Settings_handlers.delete_account_post
       ; Dream.get "/health" Health_handlers.health_check
       ; Dream.get "/metrics" Health_handlers.metrics
       ; Dream.get "/static/**" (Dream.static "./static")
       ]
;;
