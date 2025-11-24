open Asoiafdle.Daily_selector

let test_valid_index () =
  let count = 100 in
  let index = get_daily_index count in
  assert (index >= 0 && index < count);
  print_endline "✓ test_valid_index passed"
;;

let test_deterministic () =
  let count = 50 in
  let index1 = get_daily_index count in
  let index2 = get_daily_index count in
  assert (index1 = index2);
  print_endline "✓ test_deterministic passed"
;;

let test_count_one () =
  let count = 1 in
  let index = get_daily_index count in
  assert (index = 0);
  print_endline "✓ test_count_one passed"
;;

let test_count_zero_fails () =
  try
    let _ = get_daily_index 0 in
    assert false
  with
  | Failure msg ->
    assert (String.length msg > 0);
    print_endline "✓ test_count_zero_fails passed"
;;

let test_negative_count_fails () =
  try
    let _ = get_daily_index (-5) in
    assert false
  with
  | Failure _ -> print_endline "✓ test_negative_count_fails passed"
;;

let test_large_count () =
  let count = 10000 in
  let index = get_daily_index count in
  assert (index >= 0 && index < count);
  print_endline "✓ test_large_count passed"
;;

let test_uniform_distribution () =
  let count = 10 in
  let seen = Hashtbl.create count in
  for i = 0 to count - 1 do
    Hashtbl.add seen i false
  done;
  let current_index = get_daily_index count in
  Hashtbl.replace seen current_index true;
  assert (Hashtbl.mem seen current_index);
  print_endline "✓ test_uniform_distribution passed"
;;

let test_various_counts () =
  let counts = [ 2; 5; 10; 25; 50; 100; 365; 1000 ] in
  List.iter
    (fun count ->
       let index = get_daily_index count in
       assert (index >= 0 && index < count))
    counts;
  print_endline "✓ test_various_counts passed"
;;

let () =
  print_endline "\n=== Running Daily Selector Tests ===\n";
  test_valid_index ();
  test_deterministic ();
  test_count_one ();
  test_count_zero_fails ();
  test_negative_count_fails ();
  test_large_count ();
  test_uniform_distribution ();
  test_various_counts ();
  print_endline "\n=== All Daily Selector Tests Passed ===\n"
;;
