let add_friend_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.int Caqti_type.int ->. Caqti_type.unit)
  @@ "INSERT INTO friends (user_id, friend_id) VALUES (?, ?)"
;;

let is_already_friend_query =
  let open Caqti_request.Infix in
  (Caqti_type.t2 Caqti_type.int Caqti_type.int ->? Caqti_type.int)
  @@ "SELECT 1 FROM friends WHERE user_id = ? AND friend_id = ? LIMIT 1"
;;

let is_already_friend (module Db : Caqti_lwt.CONNECTION) (user_id : int) (friend_id : int)
  =
  match%lwt Db.find_opt is_already_friend_query (user_id, friend_id) with
  | Ok (Some _) -> Lwt.return true
  | _ -> Lwt.return false
;;

let add_friend (module Db : Caqti_lwt.CONNECTION) (user_id : int) (friend_id : int) =
  Db.exec add_friend_query (user_id, friend_id)
;;

let get_global_leaderboard_query =
  let open Caqti_request.Infix in
  (Caqti_type.unit
   ->* Caqti_type.t5
         Caqti_type.string
         Caqti_type.int
         Caqti_type.int
         Caqti_type.int
         Caqti_type.float)
  @@ "SELECT \n\
     \  u.nickname, \n\
     \  COUNT(g.id) as games_played, \n\
     \  SUM(CASE WHEN g.won THEN 1 ELSE 0 END) as wins, \n\
     \  SUM(CASE WHEN g.won AND g.guesses < 4 THEN 1 ELSE 0 END) as quick_wins, \n\
     \  COALESCE(AVG(CASE WHEN g.won THEN g.guesses ELSE NULL END), 0.0) as avg_guesses \n\
     \  FROM users u LEFT JOIN games g ON u.id = g.user_id \n\
     \  GROUP BY u.id ORDER BY games_played DESC, wins DESC LIMIT 10"
;;

let get_global_leaderboard (module Db : Caqti_lwt.CONNECTION) =
  Db.collect_list get_global_leaderboard_query ()
;;

let get_friends_leaderboard_query =
  let open Caqti_request.Infix in
  (Caqti_type.int
   ->* Caqti_type.t5
         Caqti_type.string
         Caqti_type.int
         Caqti_type.int
         Caqti_type.int
         Caqti_type.float)
  @@ "SELECT \n\
     \  u.nickname, \n\
     \  COUNT(g.id) as games_played, \n\
     \  SUM(CASE WHEN g.won THEN 1 ELSE 0 END) as wins, \n\
     \  SUM(CASE WHEN g.won AND g.guesses < 4 THEN 1 ELSE 0 END) as quick_wins, \n\
     \  COALESCE(AVG(CASE WHEN g.won THEN g.guesses ELSE NULL END), 0.0) as avg_guesses \n\
     \  FROM users u JOIN friends f ON u.id = f.friend_id \n\
     \  LEFT JOIN games g ON u.id = g.user_id WHERE f.user_id = ? \n\
     \  GROUP BY u.id ORDER BY games_played DESC, wins DESC LIMIT 10"
;;

let get_friends_leaderboard (module Db : Caqti_lwt.CONNECTION) (user_id : int) =
  Db.collect_list get_friends_leaderboard_query user_id
;;
