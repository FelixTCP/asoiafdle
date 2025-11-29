(* Metrics middleware *)

(* Simple in-memory storage for metrics *)
(* In a real production app with multiple workers, this should be in Redis or aggregated *)
(* But for a single-process Dream app, this is fine *)

module Metrics_store = struct
  (* Map of (method, status) -> count *)
  let request_counts = Hashtbl.create 16

  (* Total request duration *)
  let total_duration = ref 0.0
  let total_requests = ref 0
end

let track_request handler req =
  let start_time = Unix.gettimeofday () in
  let%lwt response = handler req in
  let end_time = Unix.gettimeofday () in
  let duration = end_time -. start_time in
  (* Update metrics *)
  let method_str = Dream.method_to_string (Dream.method_ req) in
  let status_code = Dream.status_to_int (Dream.status response) in
  let key = method_str, status_code in
  (* Update count *)
  let current_count =
    Hashtbl.find_opt Metrics_store.request_counts key |> Option.value ~default:0
  in
  Hashtbl.replace Metrics_store.request_counts key (current_count + 1);
  (* Update duration *)
  Metrics_store.total_duration := !Metrics_store.total_duration +. duration;
  incr Metrics_store.total_requests;
  Lwt.return response
;;

let get_http_metrics () =
  let buffer = Buffer.create 1024 in
  (* Request counts by status and method *)
  Buffer.add_string buffer "# HELP http_requests_total Total number of HTTP requests\n";
  Buffer.add_string buffer "# TYPE http_requests_total counter\n";
  Hashtbl.iter
    (fun (meth, status) count ->
       Printf.bprintf
         buffer
         "http_requests_total{method=\"%s\",status=\"%d\"} %d\n"
         meth
         status
         count)
    Metrics_store.request_counts;
  (* Average duration *)
  if !Metrics_store.total_requests > 0
  then (
    Buffer.add_string
      buffer
      "\n# HELP http_request_duration_seconds_sum Total duration of HTTP requests\n";
    Buffer.add_string buffer "# TYPE http_request_duration_seconds_sum counter\n";
    Printf.bprintf
      buffer
      "http_request_duration_seconds_sum %f\n"
      !Metrics_store.total_duration;
    Buffer.add_string
      buffer
      "\n# HELP http_request_duration_seconds_count Total number of HTTP requests\n";
    Buffer.add_string buffer "# TYPE http_request_duration_seconds_count counter\n";
    Printf.bprintf
      buffer
      "http_request_duration_seconds_count %d\n"
      !Metrics_store.total_requests);
  Buffer.contents buffer
;;
