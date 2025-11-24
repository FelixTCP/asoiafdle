open Asoiafdle.Password

let test_hash_password () =
  let password = "SecurePassword123!" in
  let hash = Lwt_main.run (hash_password password) in
  assert (String.length hash > 0);
  assert (hash <> password);
  print_endline "✓ test_hash_password passed"
;;

let test_verify_correct_password () =
  let password = "MySecretPass456" in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password password hash) in
  assert is_valid;
  print_endline "✓ test_verify_correct_password passed"
;;

let test_verify_incorrect_password () =
  let password = "CorrectPassword" in
  let wrong_password = "WrongPassword" in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password wrong_password hash) in
  assert (not is_valid);
  print_endline "✓ test_verify_incorrect_password passed"
;;

let test_different_passwords_different_hashes () =
  let pass1 = "Password1" in
  let pass2 = "Password2" in
  let hash1 = Lwt_main.run (hash_password pass1) in
  let hash2 = Lwt_main.run (hash_password pass2) in
  assert (hash1 <> hash2);
  print_endline "✓ test_different_passwords_different_hashes passed"
;;

let test_same_password_consistent () =
  let password = "ConsistentPass789" in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid1 = Lwt_main.run (verify_password password hash) in
  let is_valid2 = Lwt_main.run (verify_password password hash) in
  assert is_valid1;
  assert is_valid2;
  print_endline "✓ test_same_password_consistent passed"
;;

let test_empty_password () =
  let password = "" in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password password hash) in
  assert is_valid;
  print_endline "✓ test_empty_password passed"
;;

let test_very_long_password () =
  let password = String.make 1000 'x' in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password password hash) in
  assert is_valid;
  print_endline "✓ test_very_long_password passed"
;;

let test_special_characters () =
  let password = "P@ssw0rd!#$%^&*()_+-=[]{}|;':\",./<>?🔒" in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password password hash) in
  assert is_valid;
  print_endline "✓ test_special_characters passed"
;;

let test_whitespace_password () =
  let password = "   \t\n  " in
  let hash = Lwt_main.run (hash_password password) in
  let is_valid = Lwt_main.run (verify_password password hash) in
  assert is_valid;
  print_endline "✓ test_whitespace_password passed"
;;

let () =
  print_endline "\n=== Running Password Tests ===\n";
  test_hash_password ();
  test_verify_correct_password ();
  test_verify_incorrect_password ();
  test_different_passwords_different_hashes ();
  test_same_password_consistent ();
  test_empty_password ();
  test_very_long_password ();
  test_special_characters ();
  test_whitespace_password ();
  print_endline "\n=== All Password Tests Passed ===\n"
;;
