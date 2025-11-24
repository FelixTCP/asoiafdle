open Asoiafdle

let get_attributes (c : Models.character) =
  ( c.allegience
  , c.region
  , c.gender
  , c.status
  , c.first_appearance
  , c.title
  , c.age_bracket
  , c.last_seen )
;;

let string_of_attributes
      (allegience, region, gender, status, first_appearance, title, age_bracket, last_seen)
  =
  Printf.sprintf
    "Allegience: %s, Region: %s, Gender: %s, Status: %s, First Appearance: %s, Title: \
     %s, Age Bracket: %s, Last Seen: %s"
    allegience
    region
    gender
    status
    first_appearance
    title
    age_bracket
    last_seen
;;

let test_duplicate_characters () =
  let characters = Seed.characters in
  let table = Hashtbl.create (List.length characters) in
  let duplicates = ref [] in
  List.iter
    (fun c ->
       let attrs = get_attributes c in
       match Hashtbl.find_opt table attrs with
       | Some existing_names -> Hashtbl.replace table attrs (c.name :: existing_names)
       | None -> Hashtbl.add table attrs [ c.name ])
    characters;
  Hashtbl.iter
    (fun attrs names ->
       if List.length names > 1
       then
         duplicates
         := Printf.sprintf
              "Attributes: [%s]\nShared by: %s"
              (string_of_attributes attrs)
              (String.concat ", " names)
            :: !duplicates)
    table;
  if List.length !duplicates > 0
  then (
    Printf.printf "Found %d sets of duplicate characters:\n\n" (List.length !duplicates);
    List.iter (fun msg -> Printf.printf "%s\n\n" msg) !duplicates;
    exit 1)
  else Printf.printf "No duplicate characters found.\n"
;;

let () = test_duplicate_characters ()
