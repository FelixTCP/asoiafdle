open Asoiafdle.Models

let test_valid_character () =
  let c : character =
    { name = "Test Character"
    ; allegience = "Test House"
    ; region = "Test Region"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "Test Book"
    ; title = "Test Title"
    ; age_bracket = "Adult"
    ; last_seen = "Test Location"
    }
  in
  assert (c.name = "Test Character");
  assert (c.allegience = "Test House");
  print_endline "✓ test_valid_character passed"
;;

let test_valid_user () =
  let u : user =
    { id = 1
    ; email = "test@example.com"
    ; password_hash = "hashed_password"
    ; nickname = "TestUser"
    ; friend_code = "ABCD-EFGH"
    ; created_at = "2024-01-01 00:00:00"
    }
  in
  assert (u.id = 1);
  assert (u.email = "test@example.com");
  assert (u.nickname = "TestUser");
  assert (u.friend_code = "ABCD-EFGH");
  print_endline "✓ test_valid_user passed"
;;

let test_character_empty_fields () =
  let c : character =
    { name = ""
    ; allegience = ""
    ; region = ""
    ; gender = ""
    ; status = ""
    ; first_appearance = ""
    ; title = ""
    ; age_bracket = ""
    ; last_seen = ""
    }
  in
  assert (c.name = "");
  print_endline "✓ test_character_empty_fields passed"
;;

let test_user_special_email () =
  let u : user =
    { id = 2
    ; email = "test+tag@sub.example.com"
    ; password_hash = "hash"
    ; nickname = "User123"
    ; friend_code = "TEST-CODE"
    ; created_at = "2024-01-01"
    }
  in
  assert (String.contains u.email '+');
  assert (String.contains u.email '@');
  print_endline "✓ test_user_special_email passed"
;;

let test_character_unicode () =
  let c : character =
    { name = "Daenerys Targaryen 🐉"
    ; allegience = "Targaryen"
    ; region = "Essos"
    ; gender = "Female"
    ; status = "Alive"
    ; first_appearance = "A Game of Thrones"
    ; title = "Khaleesi"
    ; age_bracket = "Young Adult"
    ; last_seen = "Meereen"
    }
  in
  assert (String.length c.name > 0);
  print_endline "✓ test_character_unicode passed"
;;

let test_user_long_nickname () =
  let long_nick = String.make 100 'x' in
  let u : user =
    { id = 3
    ; email = "test@example.com"
    ; password_hash = "hash"
    ; nickname = long_nick
    ; friend_code = "CODE-1234"
    ; created_at = "2024-01-01"
    }
  in
  assert (String.length u.nickname = 100);
  print_endline "✓ test_user_long_nickname passed"
;;

let test_duplicate_attributes () =
  let c1 : character =
    { name = "Character 1"
    ; allegience = "House A"
    ; region = "Region A"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "Book 1"
    ; title = "Lord"
    ; age_bracket = "Adult"
    ; last_seen = "Location A"
    }
  in
  let c2 : character =
    { name = "Character 2"
    ; allegience = "House A"
    ; region = "Region A"
    ; gender = "Male"
    ; status = "Alive"
    ; first_appearance = "Book 1"
    ; title = "Lord"
    ; age_bracket = "Adult"
    ; last_seen = "Location A"
    }
  in
  assert (c1.name <> c2.name);
  assert (c1.allegience = c2.allegience);
  print_endline "✓ test_duplicate_attributes passed"
;;

let () =
  print_endline "\n=== Running Core Models Tests ===\n";
  test_valid_character ();
  test_valid_user ();
  test_character_empty_fields ();
  test_user_special_email ();
  test_character_unicode ();
  test_user_long_nickname ();
  test_duplicate_attributes ();
  print_endline "\n=== All Core Models Tests Passed ===\n"
;;
