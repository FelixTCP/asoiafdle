open Tyxml.Html

let version = "v0.1.0"

let github_svg =
  [ Tyxml.Svg.path
      ~a:
        [ Tyxml.Svg.a_fill_rule `Evenodd
        ; Tyxml.Svg.a_d
            "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 \
             9.504.5.092.682-.217.682-.483 \
             0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 \
             1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 \
             2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 \
             0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 \
             1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 \
             2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 \
             2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 \
             2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 \
             17.522 2 12 2z"
        ; Tyxml.Svg.Unsafe.string_attrib "clip-rule" "evenodd"
        ]
      []
  ]
;;

let footer () =
  footer
    ~a:
      [ a_class
          [ "bg-slate-800"; "border-t"; "border-slate-700"; "px-4"; "py-4"; "mt-auto" ]
      ]
    [ div
        ~a:[ a_class [ "max-w-6xl"; "mx-auto" ] ]
        [ div
            ~a:
              [ a_class
                  [ "flex"
                  ; "flex-col"
                  ; "md:flex-row"
                  ; "justify-between"
                  ; "items-center"
                  ; "gap-4"
                  ; "text-sm"
                  ; "text-slate-400"
                  ]
              ]
            [ div
                ~a:[ a_class [ "flex"; "items-center"; "gap-2" ] ]
                [ span
                    [ txt (Printf.sprintf "Version %s | made with " version)
                    ; span ~a:[ a_class [ "text-red-500" ] ] [ txt "💙" ]
                    ; txt " by "
                    ; a
                        ~a:
                          [ a_href "https://github.com/FelixTCP"
                          ; a_target "_blank"
                          ; a_rel [ `Noopener; `Noreferrer ]
                          ; a_class [ "hover:text-asoiaf-gold"; "transition-colors" ]
                          ]
                        [ txt "FelixTCP" ]
                    ]
                ]
            ; div
                ~a:[ a_class [ "flex"; "items-center"; "gap-2" ] ]
                [ span [ txt "All characters © George R. R. Martin" ] ]
            ; div
                ~a:[ a_class [ "flex"; "items-center"; "gap-2" ] ]
                [ a
                    ~a:
                      [ a_href "https://github.com/FelixTCP/asoiafdle"
                      ; a_target "_blank"
                      ; a_rel [ `Noopener; `Noreferrer ]
                      ; a_class
                          [ "flex"
                          ; "items-center"
                          ; "gap-2"
                          ; "px-3"
                          ; "py-1.5"
                          ; "bg-slate-700"
                          ; "hover:bg-slate-600"
                          ; "rounded-md"
                          ; "transition-colors"
                          ]
                      ]
                    [ svg
                        ~a:
                          [ Tyxml.Svg.a_class [ "w-5"; "h-5" ]
                          ; Tyxml.Svg.a_fill `CurrentColor
                          ; Tyxml.Svg.a_viewBox (0., 0., 24., 24.)
                          ]
                        github_svg
                    ; span [ txt "View on GitHub" ]
                    ]
                ]
            ]
        ]
    ]
;;

let navbar ?user ~csrf () =
  let auth_section =
    match user with
    | Some _u ->
      [ a
          ~a:
            [ a_href "/settings"
            ; a_class [ "hover:text-asoiaf-gold"; "transition-colors" ]
            ]
          [ txt "Settings" ]
      ; form
          ~a:[ a_method `Post; a_action "/logout"; a_class [ "inline" ] ]
          [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
          ; button
              ~a:
                [ a_button_type `Submit
                ; a_class [ "hover:text-asoiaf-gold"; "transition-colors" ]
                ]
              [ txt "Logout" ]
          ]
      ]
    | None ->
      [ a
          ~a:
            [ a_href "/login"; a_class [ "hover:text-asoiaf-gold"; "transition-colors" ] ]
          [ txt "Login" ]
      ]
  in
  nav
    ~a:[ a_class [ "bg-slate-800"; "border-b"; "border-slate-700"; "px-4"; "py-3" ] ]
    [ div
        ~a:
          [ a_class [ "max-w-6xl"; "mx-auto"; "flex"; "justify-between"; "items-center" ]
          ]
        [ a
            ~a:
              [ a_href "/"
              ; a_class
                  [ "text-xl"
                  ; "md:text-2xl"
                  ; "font-bold"
                  ; "text-asoiaf-gold"
                  ; "hover:text-yellow-400"
                  ]
              ]
            [ txt "ASOIAFDLE" ]
        ; div
            ~a:[ a_class [ "flex"; "gap-4"; "items-center" ] ]
            ([ a
                 ~a:
                   [ a_href "/leaderboard"
                   ; a_class [ "hover:text-asoiaf-gold"; "transition-colors" ]
                   ]
                 [ txt "Leaderboard" ]
             ]
             @ auth_section)
        ]
    ]
;;

let layout navbar_content body_content =
  let page =
    html
      ~a:[ a_lang "en"; a_class [ "h-full" ] ]
      (head
         (title (txt "ASOIAFDLE"))
         [ meta ~a:[ a_charset "UTF-8" ] ()
         ; meta
             ~a:[ a_name "viewport"; a_content "width=device-width, initial-scale=1.0" ]
             ()
         ; link ~rel:[ `Stylesheet ] ~href:"/static/output.css" ()
         ; script ~a:[ a_src "https://unpkg.com/htmx.org@1.9.10" ] (txt "")
         ])
      (body
         ~a:
           [ a_class
               [ "h-full"
               ; "flex"
               ; "flex-col"
               ; "bg-gradient-to-b"
               ; "from-slate-900"
               ; "to-slate-800"
               ; "text-white"
               ; "overflow-x-hidden"
               ; "overflow-y-auto"
               ]
           ]
         [ navbar_content
         ; main ~a:[ a_class [ "flex-1"; "p-4"; "md:p-6" ] ] [ body_content ]
         ; footer ()
         ])
  in
  Format.asprintf "%a" (pp ()) page
;;
