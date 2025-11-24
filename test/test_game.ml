open Asoiafdle.Models
open Asoiafdle.Game

let test_compare () =
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
  print_endline "test_compare passed"
;;

let () = test_compare ()
