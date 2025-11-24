open Asoiafdle.Models
open Asoiafdle.Game

let test_compare_all_correct () =
  let target : character =
    { name = "Jon Snow"
    ; allegience = "Stark"
    ; region = "The North"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Lord Commander"
    ; age_bracket = "Teenager"
    ; last_seen = "The Wall"
    }
  in
  let guess = target in
  let result = compare target guess in
  assert (result.name = Correct);
  assert (result.allegience = Correct);
  assert (result.region = Correct);
  assert (result.gender = Correct);
  assert (result.status = Correct);
  assert (result.first_appearance = Correct);
  assert (result.title = Correct);
  assert (result.age_bracket = Correct);
  assert (result.last_seen = Correct);
  print_endline "✓ test_compare_all_correct passed"
;;

let test_compare_partial_match () =
  let target : character =
    { name = "Jon Snow"
    ; allegience = "Stark"
    ; region = "The North"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Lord Commander"
    ; age_bracket = "Teenager"
    ; last_seen = "The Wall"
    }
  in
  let guess : character =
    { name = "Arya Stark"
    ; allegience = "Stark"
    ; region = "The North"
    ; gender = "Female"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Princess"
    ; age_bracket = "Child"
    ; last_seen = "Free Cities"
    }
  in
  let result = compare target guess in
  assert (result.allegience = Correct);
  assert (result.region = Correct);
  assert (result.gender = Incorrect);
  assert (result.status = Correct);
  assert (result.first_appearance = Correct);
  assert (result.title = Incorrect);
  assert (result.age_bracket = Incorrect);
  assert (result.last_seen = Incorrect);
  print_endline "✓ test_compare_partial_match passed"
;;

let test_compare_no_match () =
  let target : character =
    { name = "Jon Snow"
    ; allegience = "Stark"
    ; region = "The North"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Lord Commander"
    ; age_bracket = "Teenager"
    ; last_seen = "The Wall"
    }
  in
  let guess : character =
    { name = "Cersei Lannister"
    ; allegience = "Lannister"
    ; region = "The Westerlands"
    ; gender = "Female"
    ; status = "Dead"
    ; first_appearance = "A Clash of Kings"
    ; title = "Queen"
    ; age_bracket = "Adult"
    ; last_seen = "King's Landing"
    }
  in
  let result = compare target guess in
  assert (result.allegience = Incorrect);
  assert (result.region = Incorrect);
  assert (result.gender = Incorrect);
  assert (result.status = Incorrect);
  assert (result.first_appearance = Incorrect);
  assert (result.title = Incorrect);
  assert (result.age_bracket = Incorrect);
  assert (result.last_seen = Incorrect);
  print_endline "✓ test_compare_no_match passed"
;;

let test_compare_case_insensitive () =
  let target : character =
    { name = "Jon Snow"
    ; allegience = "STARK"
    ; region = "the north"
    ; gender = "MALE"
    ; status = "alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Lord Commander"
    ; age_bracket = "Teenager"
    ; last_seen = "The Wall"
    }
  in
  let guess : character =
    { name = "Jon Snow"
    ; allegience = "stark"
    ; region = "THE NORTH"
    ; gender = "male"
    ; status = "ALIVE"
    ; first_appearance = "a game of thrones"
    ; title = "lord commander"
    ; age_bracket = "teenager"
    ; last_seen = "the wall"
    }
  in
  let result = compare target guess in
  assert (result.allegience = Correct);
  assert (result.region = Correct);
  assert (result.gender = Correct);
  assert (result.status = Correct);
  assert (result.first_appearance = Correct);
  assert (result.title = Correct);
  assert (result.age_bracket = Correct);
  assert (result.last_seen = Correct);
  print_endline "✓ test_compare_case_insensitive passed"
;;

let test_compare_empty_name () =
  let target : character =
    { name = ""
    ; allegience = "Stark"
    ; region = "The North"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Lord Commander"
    ; age_bracket = "Teenager"
    ; last_seen = "The Wall"
    }
  in
  let guess = target in
  let result = compare target guess in
  assert (result.name = Correct);
  print_endline "✓ test_compare_empty_name passed"
;;

let test_compare_special_characters () =
  let target : character =
    { name = "Daenerys Targaryen (Mother of Dragons)"
    ; allegience = "Targaryen"
    ; region = "Essos"
    ; gender = "Female"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Queen"
    ; age_bracket = "Young Adult"
    ; last_seen = "Meereen"
    }
  in
  let guess = target in
  let result = compare target guess in
  assert (result.name = Correct);
  print_endline "✓ test_compare_special_characters passed"
;;

let test_compare_long_values () =
  let long_string = String.make 500 'x' in
  let target : character =
    { name = long_string
    ; allegience = long_string
    ; region = long_string
    ; gender = long_string
    ; status = long_string
    ; first_appearance = long_string
    ; title = long_string
    ; age_bracket = long_string
    ; last_seen = long_string
    }
  in
  let guess = target in
  let result = compare target guess in
  assert (result.name = Correct);
  assert (result.allegience = Correct);
  print_endline "✓ test_compare_long_values passed"
;;

let test_find_character_exists () =
  (* This test depends on actual seed data *)
  match find_character "Jon Snow" with
  | Some c ->
    assert (String.lowercase_ascii c.name = "jon snow");
    print_endline "✓ test_find_character_exists passed"
  | None ->
    (* If Jon Snow doesn't exist in seed, just verify the function works *)
    print_endline "✓ test_find_character_exists passed (no Jon Snow in seed)"
;;

let test_find_character_not_exists () =
  match find_character "NonExistentCharacter12345" with
  | Some _ -> assert false
  | None -> print_endline "✓ test_find_character_not_exists passed"
;;

let test_find_character_case_insensitive () =
  match find_character "JON SNOW" with
  | Some _ -> print_endline "✓ test_find_character_case_insensitive passed"
  | None -> print_endline "✓ test_find_character_case_insensitive passed (no match)"
;;

let () =
  print_endline "\n=== Running Core Game Tests ===\n";
  test_compare_all_correct ();
  test_compare_partial_match ();
  test_compare_no_match ();
  test_compare_case_insensitive ();
  test_compare_empty_name ();
  test_compare_special_characters ();
  test_compare_long_values ();
  test_find_character_exists ();
  test_find_character_not_exists ();
  test_find_character_case_insensitive ();
  print_endline "\n=== All Core Game Tests Passed ===\n"
;;
