open Models

type match_status =
  | Correct
  | Incorrect
[@@deriving yojson]

type guess_result =
  { name : match_status
  ; allegience : match_status
  ; region : match_status
  ; gender : match_status
  ; status : match_status
  ; first_appearance : match_status
  ; title : match_status
  ; age_bracket : match_status
  ; last_seen : match_status
  }
[@@deriving yojson]

let compare (target : character) (guess : character) : guess_result =
  let check v1 v2 =
    if String.lowercase_ascii v1 = String.lowercase_ascii v2 then Correct else Incorrect
  in
  { name = check target.name guess.name
  ; allegience = check target.allegience guess.allegience
  ; region = check target.region guess.region
  ; gender = check target.gender guess.gender
  ; status = check target.status guess.status
  ; first_appearance = check target.first_appearance guess.first_appearance
  ; title = check target.title guess.title
  ; age_bracket = check target.age_bracket guess.age_bracket
  ; last_seen = check target.last_seen guess.last_seen
  }
;;

let get_daily_character () =
  let count = List.length Seed.characters in
  if count = 0
  then failwith "No characters in seed"
  else List.nth Seed.characters (Daily_selector.get_daily_index count)
;;

let find_character (name : string) : character option =
  List.find_opt
    (fun (c : Models.character) ->
       String.lowercase_ascii c.name = String.lowercase_ascii name)
    Seed.characters
;;
