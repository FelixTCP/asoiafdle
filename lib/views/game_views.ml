open Tyxml.Html

let guess_input_js =
  "\n\
  \  const val = this.value.toLowerCase();\n\
  \  const datalist = document.getElementById('characters');\n\
  \  datalist.innerHTML = '';\n\
  \  if (val.length >= 3) {\n\
  \    const matches = ALL_CHARACTERS.filter(c => c.toLowerCase().includes(val));\n\
  \    matches.forEach(c => {\n\
  \      const option = document.createElement('option');\n\
  \      option.value = c;\n\
  \      datalist.appendChild(option);\n\
  \    });\n\
  \  }\n"
;;

let guess_keydown_js =
  "\n\
  \  if (event.key === 'Tab' || event.key === 'Enter') {\n\
  \    const val = this.value.toLowerCase();\n\
  \    if (val.length < 3) return;\n\
  \    const options = document.getElementById('characters').options;\n\
  \    if (options.length > 0) {\n\
  \       this.value = options[0].value;\n\
  \       if (event.key === 'Tab') event.preventDefault();\n\
  \    }\n\
  \  }\n"
;;

let attribute_headers =
  [ "Name"
  ; "Allegience"
  ; "Region"
  ; "Gender"
  ; "Status"
  ; "First Appearance"
  ; "Title"
  ; "Age"
  ; "Last Seen"
  ]
;;

let index_page ?user ?(guesses = "") ~csrf ~game_complete () =
  let nav = Layout.navbar ?user ~csrf () in
  let welcome_msg =
    match user with
    | Some _ -> div []
    | None ->
      p
        ~a:[ a_class [ "text-center"; "mb-4" ] ]
        [ a
            ~a:[ a_href "/login"; a_class [ "text-blue-400"; "hover:underline" ] ]
            [ txt "Login" ]
        ; txt " or "
        ; a
            ~a:[ a_href "/register"; a_class [ "text-blue-400"; "hover:underline" ] ]
            [ txt "Register" ]
        ; txt " to save your progress!"
        ]
  in
  let all_characters_json =
    let open Ppx_yojson_conv_lib.Yojson_conv.Primitives in
    [%yojson_of: string list]
      (List.map (fun (c : Models.character) -> c.name) Seed.characters)
    |> Yojson.Safe.to_string
  in
  let form_section =
    if game_complete
    then
      div
        ~a:
          [ a_class
              [ "bg-blue-900"; "border"; "border-blue-500"; "rounded-lg"; "p-4"; "mb-4" ]
          ]
        [ p
            ~a:[ a_class [ "text-center"; "text-lg" ] ]
            [ txt "Game complete! Come back tomorrow for a new character." ]
        ]
    else
      div
        [ div
            ~a:[ a_class [ "mb-4"; "text-sm"; "text-gray-400" ] ]
            [ p [ txt "Guess the character based on their attributes!" ]
            ; p [ txt "You have 6 guesses. Good luck!" ]
            ]
        ; script
            (Unsafe.data
               (Printf.sprintf "const ALL_CHARACTERS = %s;" all_characters_json))
        ; form
            ~a:
              [ a_method `Post
              ; Unsafe.string_attrib "hx-post" "/guess"
              ; Unsafe.string_attrib "hx-target" "#results"
              ; Unsafe.string_attrib "hx-swap" "beforeend"
              ; a_class [ "mb-8"; "max-w-md"; "mx-auto" ]
              ; Unsafe.string_attrib
                  "hx-on::after-request"
                  "if(event.detail.target.id === 'results') { this.reset(); \
                   document.getElementById('characters').innerHTML = ''; }"
              ]
            [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
            ; div
                ~a:[ a_class [ "flex"; "gap-2" ] ]
                [ input
                    ~a:
                      [ a_input_type `Text
                      ; a_name "guess"
                      ; a_id "guess-input"
                      ; a_placeholder "Start typing character name..."
                      ; a_class [ "input"; "flex-1"; "min-w-0" ]
                      ; a_list "characters"
                      ; a_autocomplete `Off
                      ; a_oninput guess_input_js
                      ; a_onkeydown guess_keydown_js
                      ; a_required ()
                      ]
                    ()
                ; datalist ~a:[ a_id "characters" ] ()
                ; button ~a:[ a_button_type `Submit; a_class [ "btn" ] ] [ txt "Guess" ]
                ]
            ]
        ]
  in
  let content =
    div
      ~a:[ a_class [ "max-w-6xl"; "mx-auto"; "text-center" ] ]
      [ h2
          ~a:[ a_class [ "text-3xl"; "font-bold"; "mb-6" ] ]
          [ txt "Guess the Character" ]
      ; welcome_msg
      ; form_section
      ; div
          ~a:[ a_id "game-container"; a_class [ "overflow-x-auto" ] ]
          [ div
              ~a:[ a_class [ "min-w-[600px]" ] ]
              [ div
                  ~a:
                    [ a_class
                        [ "grid"
                        ; "grid-cols-9"
                        ; "gap-2"
                        ; "text-center"
                        ; "text-[10px]"
                        ; "md:text-sm"
                        ; "mb-2"
                        ; "font-bold"
                        ]
                    ]
                  (List.map
                     (fun title -> div ~a:[ a_class [ "p-2" ] ] [ txt title ])
                     attribute_headers)
              ; div ~a:[ a_id "results"; a_class [ "space-y-2" ] ] [ Unsafe.data guesses ]
              ]
          ]
      ]
  in
  Layout.layout nav content
;;

let guess_result (c : Models.character) (r : Game.guess_result) =
  let status_class s =
    match s with
    | Game.Correct -> "bg-green-600"
    | Game.Incorrect -> "bg-red-600"
  in
  let cell content status =
    div
      ~a:
        [ a_class
            [ "p-2"
            ; "rounded"
            ; status
            ; "flex"
            ; "items-center"
            ; "justify-center"
            ; "min-h-[3rem]"
            ]
        ]
      [ span [ txt content ] ]
  in
  let row =
    div
      ~a:
        [ a_class
            [ "grid"
            ; "grid-cols-9"
            ; "gap-2"
            ; "text-center"
            ; "text-[10px]"
            ; "md:text-sm"
            ; "mb-2"
            ]
        ]
      ([ div
           ~a:
             [ a_class
                 [ "p-2"
                 ; "rounded"
                 ; "flex"
                 ; "items-center"
                 ; "justify-center"
                 ; "min-h-[3rem]"
                 ]
             ]
           [ span ~a:[ a_class [ "font-bold"; "text-asoiaf-gold" ] ] [ txt c.name ] ]
       ]
       @ List.map2
           (fun content status -> cell content status)
           [ c.allegience
           ; c.region
           ; c.gender
           ; c.status
           ; c.first_appearance
           ; c.title
           ; c.age_bracket
           ; c.last_seen
           ]
           [ status_class r.allegience
           ; status_class r.region
           ; status_class r.gender
           ; status_class r.status
           ; status_class r.first_appearance
           ; status_class r.title
           ; status_class r.age_bracket
           ; status_class r.last_seen
           ])
  in
  Format.asprintf "%a" (pp_elt ()) row
;;
