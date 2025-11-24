open Models

let load_characters_from_file filename =
  try
    let json = Yojson.Safe.from_file filename in
    let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
    match [%of_yojson: character list] json with
    | characters -> characters
    | exception _ -> failwith ("Invalid JSON format in " ^ filename)
  with
  | Sys_error msg -> failwith ("Could not read file " ^ filename ^ ": " ^ msg)
  | Yojson.Json_error msg -> failwith ("JSON parsing error in " ^ filename ^ ": " ^ msg)
;;

let characters = load_characters_from_file "resources/characters.json"
