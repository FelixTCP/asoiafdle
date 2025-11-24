open Lwt.Infix
open Caqti_request.Infix

(* Read and parse schema.sql file *)
let read_schema_file () =
  let schema_path = "schema.sql" in
  Lwt_io.with_file ~mode:Lwt_io.Input schema_path (fun ic -> Lwt_io.read ic)
;;

let parse_sql_statements sql =
  (* Split by semicolons and filter out empty statements *)
  String.split_on_char ';' sql
  |> List.map String.trim
  |> List.filter (fun s -> String.length s > 0)
;;

let migrate pool =
  Caqti_lwt_unix.Pool.use
    (fun (module Db : Caqti_lwt.CONNECTION) ->
       let%lwt schema_content = read_schema_file () in
       let statements = parse_sql_statements schema_content in
       let rec exec_statements = function
         | [] -> Lwt.return (Ok ())
         | stmt :: rest ->
           let query = (Caqti_type.unit ->. Caqti_type.unit) @@ stmt in
           (match%lwt Db.exec query () with
            | Ok () -> exec_statements rest
            | Error e -> Lwt.return (Error e))
       in
       exec_statements statements)
    pool
;;

let insert_character_query =
  let open Caqti_request.Infix in
  (Caqti_type.t8
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
     Caqti_type.string
   ->. Caqti_type.unit)
  @@ "INSERT INTO characters \n\
     \  (name, allegience, region, gender, status, first_appearance, title, age_bracket) \n\
     \  VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
;;

let insert_character (module Db : Caqti_lwt.CONNECTION) (c : Models.character) =
  Db.exec
    insert_character_query
    ( c.name
    , c.allegience
    , c.region
    , c.gender
    , c.status
    , c.first_appearance
    , c.title
    , c.age_bracket )
;;

let count_characters_query =
  (Caqti_type.unit ->! Caqti_type.int) @@ "SELECT COUNT(*) FROM characters"
;;

let seed pool =
  Caqti_lwt_unix.Pool.use
    (fun (module Db : Caqti_lwt.CONNECTION) ->
       match%lwt Db.find count_characters_query () with
       | Ok 0 ->
         Lwt_list.iter_s
           (fun c ->
              match%lwt insert_character (module Db) c with
              | Ok () -> Lwt.return_unit
              | Error err ->
                Lwt_io.eprintf
                  "Failed to insert character %s: %s\n"
                  c.name
                  (Caqti_error.show err))
           Seed.characters
         >>= fun () -> Lwt.return (Ok ())
       | Ok _ -> Lwt.return (Ok ())
       | Error err -> Lwt.return (Error err))
    pool
;;

let init_db uri =
  let pool_config = Caqti_pool_config.create ~max_size:5 () in
  match Caqti_lwt_unix.connect_pool ~pool_config (Uri.of_string uri) with
  | Error err -> Lwt.fail_with (Caqti_error.show err)
  | Ok pool ->
    migrate pool
    >>= (function
     | Ok () ->
       seed pool
       >>= (function
        | Ok () -> Lwt_io.printf "Database initialized and seeded\n"
        | Error err -> Lwt.fail_with (Caqti_error.show err))
     | Error err -> Lwt.fail_with (Caqti_error.show err))
;;

let save_game_query =
  let open Caqti_request.Infix in
  (Caqti_type.t6
     Caqti_type.int
     Caqti_type.int
     Caqti_type.int
     Caqti_type.string
     Caqti_type.string
     Caqti_type.bool
   ->. Caqti_type.unit)
  @@ "INSERT OR REPLACE INTO games  \n\
     \  (user_id, character_id, guesses, guess_names, date,won)  \n\
     \  VALUES (?, ?, ?, ?, ?, ?)"
;;

let save_game
      (module Db : Caqti_lwt.CONNECTION)
      ~user_id
      ~character_id
      ~guesses
      ~guess_names
      ~date
      ~won
  =
  Db.exec save_game_query (user_id, character_id, guesses, guess_names, date, won)
;;

let get_today_game_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.int Caqti_type.string
   ->? Caqti_type.t5
         Caqti_type.int
         Caqti_type.int
         Caqti_type.(option string)
         Caqti_type.bool
         Caqti_type.string)
  @@ "SELECT character_id, guesses, guess_names, won, date FROM games \n\
     \  WHERE user_id = ? AND date = ?"
;;

let get_today_game (module Db : Caqti_lwt.CONNECTION) ~user_id ~date =
  Db.find_opt get_today_game_query (user_id, date)
;;

let get_game_guesses_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.int Caqti_type.string
   ->? Caqti_type.t3 Caqti_type.string Caqti_type.int Caqti_type.bool)
  @@ "SELECT COALESCE((SELECT GROUP_CONCAT(name, '|') FROM (\n\
     \        SELECT name FROM characters c \n\
     \        JOIN games g ON g.character_id = c.id \n\
     \        WHERE g.user_id = ? AND g.date = ?\n\
     \        LIMIT g.guesses\n\
     \      )), '') as guess_names,\n\
     \      COALESCE(guesses, 0) as num_guesses,\n\
     \      COALESCE(won, 0) as won\n\
     \     FROM games WHERE user_id = ? AND date = ? LIMIT 1"
;;

let get_game_guesses (module Db : Caqti_lwt.CONNECTION) ~user_id ~date =
  Db.find_opt get_game_guesses_query (user_id, date)
;;
