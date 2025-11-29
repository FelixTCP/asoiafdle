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
