open Tyxml.Html

let reveal_code_js =
  "\n\
  \  const cover = document.getElementById('code-cover');\n\
  \  const btn = this;\n\
  \  if (cover.style.display === 'none') {\n\
  \    cover.style.display = '';\n\
  \    btn.textContent = '👁️‍🗨️';\n\
  \    btn.title = 'Reveal code';\n\
  \  } else {\n\
  \    cover.style.display = 'none';\n\
  \    btn.textContent = '👁️';\n\
  \    btn.title = 'Hide code';\n\
  \  }\n"
;;

let copy_code_js code =
  Printf.sprintf
    "\n\
    \  const code = '%s';\n\
    \  navigator.clipboard.writeText(code).then(() => {\n\
    \    const btn = this;\n\
    \    const originalText = btn.textContent;\n\
    \    btn.textContent = '✓ Copied!';\n\
    \    btn.classList.add('bg-green-600');\n\
    \    setTimeout(() => {\n\
    \      btn.textContent = originalText;\n\
    \      btn.classList.remove('bg-green-600');\n\
    \    }, 2000);\n\
    \  });\n"
    code
;;

let leaderboard_table_headers =
  [ "Player", "text-left"
  ; "Games", "text-center"
  ; "Wins", "text-center"
  ; "Quick Wins", "text-center"
  ; "Avg Guesses", "text-center"
  ]
;;

let friend_table_headers =
  [ "Friend", "text-left"
  ; "Games", "text-center"
  ; "Wins", "text-center"
  ; "Quick Wins", "text-center"
  ; "Avg Guesses", "text-center"
  ]
;;

let make_table_header headers =
  thead
    [ tr
        ~a:[ a_class [ "border-b"; "border-slate-700" ] ]
        (List.map
           (fun (title, align) ->
              let base_classes = [ align; "p-2" ] in
              let attribs =
                if title = "Quick Wins"
                then
                  [ a_class base_classes
                  ; Unsafe.string_attrib
                      "tooltip"
                      "Correct answers within first three guesses"
                  ]
                else [ a_class base_classes ]
              in
              th ~a:attribs [ txt title ])
           headers)
    ]
;;

let make_table_row (nickname, games, wins, quick_wins, avg_guesses) =
  tr
    [ td ~a:[ a_class [ "p-2" ] ] [ txt nickname ]
    ; td ~a:[ a_class [ "text-center"; "p-2" ] ] [ txt (string_of_int games) ]
    ; td ~a:[ a_class [ "text-center"; "p-2" ] ] [ txt (string_of_int wins) ]
    ; td ~a:[ a_class [ "text-center"; "p-2" ] ] [ txt (string_of_int quick_wins) ]
    ; td
        ~a:[ a_class [ "text-center"; "p-2" ] ]
        [ txt (Printf.sprintf "%.1f" avg_guesses) ]
    ]
;;

let leaderboard_page ?user ~global ~friends ~csrf () =
  let nav = Layout.navbar ?user ~csrf () in
  let global_table =
    let rows = List.map make_table_row global in
    div
      ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-4"; "overflow-x-auto" ] ]
      [ table
          ~a:[ a_class [ "w-full"; "min-w-[500px]" ] ]
          ~thead:(make_table_header leaderboard_table_headers)
          rows
      ]
  in
  let friends_section =
    if List.length friends > 0
    then (
      let rows = List.map make_table_row friends in
      div
        ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-4"; "overflow-x-auto" ] ]
        [ table
            ~a:[ a_class [ "w-full"; "min-w-[500px]" ] ]
            ~thead:(make_table_header friend_table_headers)
            rows
        ])
    else
      div
        ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-4"; "overflow-x-auto" ] ]
        [ p
            ~a:[ a_class [ "text-gray-400" ] ]
            [ txt "No friends yet. Add friends to see their scores!" ]
        ]
  in
  let add_friend_section =
    match user with
    | Some u ->
      div
        ~a:[ a_class [ "mt-8"; "bg-slate-800"; "rounded-lg"; "p-6" ] ]
        [ h3 ~a:[ a_class [ "text-xl"; "font-bold"; "mb-4" ] ] [ txt "Add Friend" ]
        ; div
            ~a:[ a_class [ "mb-4" ] ]
            [ div
                ~a:[ a_class [ "flex"; "items-center"; "gap-2" ] ]
                [ p
                    ~a:[ a_class [ "text-sm"; "text-gray-400" ] ]
                    [ txt "Your friend code:" ]
                ; div
                    ~a:[ a_class [ "relative"; "inline-block" ] ]
                    [ span
                        ~a:
                          [ a_id "friend-code"
                          ; a_class
                              [ "font-mono"; "text-asoiaf-gold"; "text-lg"; "select-all" ]
                          ]
                        [ txt u.Models.friend_code ]
                    ; div
                        ~a:
                          [ a_id "code-cover"
                          ; a_class
                              [ "absolute"
                              ; "inset-0"
                              ; "bg-slate-600"
                              ; "rounded"
                              ; "text-center"
                              ; "text-gray-400"
                              ]
                          ; a_style ""
                          ]
                        [ txt "[ hidden ]" ]
                    ]
                ; button
                    ~a:
                      [ Unsafe.string_attrib "onclick" reveal_code_js
                      ; a_class
                          [ "px-3"
                          ; "py-1"
                          ; "bg-slate-700"
                          ; "hover:bg-slate-600"
                          ; "rounded"
                          ; "transition-colors"
                          ; "text-sm"
                          ]
                      ; a_title "Reveal code"
                      ]
                    [ txt "👁️‍🗨️" ]
                ; button
                    ~a:
                      [ Unsafe.string_attrib "onclick" (copy_code_js u.Models.friend_code)
                      ; a_class
                          [ "px-3"
                          ; "py-1"
                          ; "bg-slate-700"
                          ; "hover:bg-slate-600"
                          ; "rounded"
                          ; "transition-colors"
                          ; "text-sm"
                          ]
                      ; a_title "Copy to clipboard"
                      ]
                    [ txt "📋 Copy" ]
                ]
            ]
        ; form
            ~a:
              [ a_method `Post
              ; Unsafe.string_attrib "hx-post" "/add-friend"
              ; Unsafe.string_attrib "hx-target" "#friend-result"
              ; Unsafe.string_attrib "hx-swap" "innerHTML"
              ; a_class [ "mt-4" ]
              ]
            [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
            ; input
                ~a:
                  [ a_input_type `Text
                  ; a_name "friend_code"
                  ; a_placeholder "Enter friend code..."
                  ; a_class [ "input"; "w-full"; "max-w-md"; "mb-2" ]
                  ]
                ()
            ; button ~a:[ a_button_type `Submit; a_class [ "btn" ] ] [ txt "Add Friend" ]
            ]
        ; div ~a:[ a_id "friend-result"; a_class [ "mt-2" ] ] []
        ]
    | None ->
      p
        ~a:[ a_class [ "mt-8"; "text-center" ] ]
        [ a
            ~a:[ a_href "/login"; a_class [ "text-blue-400"; "hover:underline" ] ]
            [ txt "Login" ]
        ; txt " to add friends and compete!"
        ]
  in
  let content =
    div
      ~a:[ a_class [ "max-w-6xl"; "mx-auto" ] ]
      [ h2 ~a:[ a_class [ "text-3xl"; "font-bold"; "mb-6" ] ] [ txt "Leaderboards" ]
      ; div
          ~a:[ a_class [ "grid"; "lg:grid-cols-2"; "gap-6" ] ]
          [ div
              [ h3
                  ~a:[ a_class [ "text-2xl"; "font-bold"; "mb-4"; "text-asoiaf-gold" ] ]
                  [ txt "Global Leaderboard" ]
              ; global_table
              ]
          ; div
              [ h3
                  ~a:[ a_class [ "text-2xl"; "font-bold"; "mb-4"; "text-asoiaf-gold" ] ]
                  [ txt "Friends Leaderboard" ]
              ; friends_section
              ]
          ]
      ; add_friend_section
      ]
  in
  Layout.layout nav content
;;
