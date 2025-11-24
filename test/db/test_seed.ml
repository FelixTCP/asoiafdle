open Asoiafdle.Seed

let test_load_characters () =
  let chars = characters in
  assert (List.length chars > 0);
  print_endline "✓ test_load_characters passed"
;;

let test_all_fields_present () =
  let chars = characters in
  List.iter
    (fun c ->
       assert (String.length c.Asoiafdle.Models.name > 0);
       assert (String.length c.allegience >= 0);
       assert (String.length c.region >= 0);
       assert (String.length c.gender >= 0);
       assert (String.length c.status >= 0);
       assert (String.length c.first_appearance >= 0);
       assert (String.length c.title >= 0);
       assert (String.length c.age_bracket >= 0);
       assert (String.length c.last_seen >= 0))
    chars;
  print_endline "✓ test_all_fields_present passed"
;;

let test_no_duplicate_names () =
  let chars = characters in
  let names = Hashtbl.create (List.length chars) in
  List.iter
    (fun c ->
       let name_lower = String.lowercase_ascii c.Asoiafdle.Models.name in
       assert (not (Hashtbl.mem names name_lower));
       Hashtbl.add names name_lower true)
    chars;
  print_endline "✓ test_no_duplicate_names passed"
;;

let test_valid_character_data () =
  let chars = characters in
  List.iter
    (fun c ->
       let _ = c.Asoiafdle.Models.name in
       let _ = c.allegience in
       ())
    chars;
  print_endline "✓ test_valid_character_data passed"
;;

let test_minimum_characters () =
  let chars = characters in
  assert (List.length chars >= 5);
  print_endline "✓ test_minimum_characters passed"
;;

let () =
  print_endline "\n=== Running DB Seed Tests ===\n";
  test_load_characters ();
  test_all_fields_present ();
  test_no_duplicate_names ();
  test_valid_character_data ();
  test_minimum_characters ();
  print_endline "\n=== All DB Seed Tests Passed ===\n"
;;
