(* Configuration management *)

type config =
  { db_url : string
  ; session_secret : string
  }

let validate_session_secret secret =
  if String.length secret < 32
  then (
    Printf.eprintf
      "ERROR: SESSION_SECRET must be at least 32 characters (got %d)\n"
      (String.length secret);
    exit 1)
  else secret
;;

let load_config () =
  let db_url =
    Sys.getenv_opt "DATABASE_URL" |> Option.value ~default:"sqlite3:asoiafdle.db"
  in
  let session_secret =
    match Sys.getenv_opt "SESSION_SECRET" with
    | Some s -> validate_session_secret s
    | None ->
      Printf.eprintf "ERROR: SESSION_SECRET environment variable must be set\n";
      Printf.eprintf "Generate one with: openssl rand -base64 32\n";
      exit 1
  in
  { db_url; session_secret }
;;

let print_startup_info config =
  Printf.printf "Starting ASOIAF Wordle...\n";
  Printf.printf "Database: %s\n" config.db_url;
  flush stdout
;;
