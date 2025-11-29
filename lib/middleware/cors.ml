(* CORS middleware *)

let create ~allowed_origin =
  fun handler req ->
  let%lwt response = handler req in
  Dream.set_header response "Access-Control-Allow-Origin" allowed_origin;
  Dream.set_header response "Access-Control-Allow-Methods" "GET, POST";
  Dream.set_header response "Access-Control-Allow-Headers" "Content-Type";
  Dream.set_header response "Access-Control-Max-Age" "3600";
  Lwt.return response
;;
