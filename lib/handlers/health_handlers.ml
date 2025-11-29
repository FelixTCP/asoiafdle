(* Health check and metrics endpoints *)

(* Health check endpoint - verifies database connectivity *)
let health_check req =
  Dream.sql req (fun (module Db : Caqti_lwt.CONNECTION) ->
    let open Caqti_request.Infix in
    let query = (Caqti_type.unit ->! Caqti_type.int) @@ "SELECT 1" in
    match%lwt Db.find query () with
    | Ok _ ->
      Dream.respond
        ~headers:[ "Content-Type", "application/json" ]
        ~status:`OK
        "{\"status\":\"healthy\",\"database\":\"connected\"}"
    | Error _ ->
      Dream.respond
        ~headers:[ "Content-Type", "application/json" ]
        ~status:`Service_Unavailable
        "{\"status\":\"unhealthy\",\"database\":\"disconnected\"}")
;;

(* Application startup time for metrics *)
let start_time = Unix.time ()

(* Basic metrics endpoint in Prometheus format *)
let metrics req =
  let uptime = Unix.time () -. start_time in
  (* Get business metrics from database *)
  Dream.sql req (fun db ->
    let%lwt deletions = Metrics_db.get_counter db "total_deletions" in
    let%lwt registrations = Metrics_db.get_counter db "total_registrations" in
    let%lwt games_won = Metrics_db.get_counter db "total_games_won" in
    let del_count =
      match deletions with
      | Ok (Some c) -> c
      | _ -> 0
    in
    let reg_count =
      match registrations with
      | Ok (Some c) -> c
      | _ -> 0
    in
    let win_count =
      match games_won with
      | Ok (Some c) -> c
      | _ -> 0
    in
    (* Get HTTP metrics *)
    let http_metrics = Metrics.get_http_metrics () in
    Dream.respond
      ~headers:[ "Content-Type", "text/plain" ]
      (Printf.sprintf
         "# HELP asoiafdle_uptime_seconds Application uptime\n\
          # TYPE asoiafdle_uptime_seconds gauge\n\
          asoiafdle_uptime_seconds %f\n\n\
          # HELP asoiafdle_business_metrics Business event counters\n\
          # TYPE asoiafdle_business_metrics counter\n\
          asoiafdle_business_metrics{type=\"deletions\"} %d\n\
          asoiafdle_business_metrics{type=\"registrations\"} %d\n\
          asoiafdle_business_metrics{type=\"games_won\"} %d\n\n\
          %s"
         uptime
         del_count
         reg_count
         win_count
         http_metrics))
;;
