open Tyxml.Html

let input_field ?(label_text = "") ~name ~input_type ~placeholder ?(required = false) () =
  let label_el =
    if label_text <> ""
    then
      label
        ~a:[ a_class [ "block"; "text-sm"; "font-medium"; "mb-1" ] ]
        [ txt label_text ]
    else div []
  in
  let input_attribs =
    [ a_input_type input_type
    ; a_name name
    ; a_class [ "input"; "w-full" ]
    ; a_placeholder placeholder
    ]
    @ if required then [ a_required () ] else []
  in
  div ~a:[ a_class [ "mb-4" ] ] [ label_el; input ~a:input_attribs () ]
;;

let login_page ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ~csrf () in
  let error_msg =
    match error with
    | Some msg -> div ~a:[ a_class [ "text-red-500"; "mb-4"; "text-center" ] ] [ txt msg ]
    | None -> div []
  in
  let content =
    div
      ~a:[ a_class [ "max-w-md"; "mx-auto" ] ]
      [ h2 ~a:[ a_class [ "3xl"; "font-bold"; "mb-6"; "text-center" ] ] [ txt "Login" ]
      ; error_msg
      ; div
          ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-6" ] ]
          [ form
              ~a:[ a_method `Post; a_action "/login" ]
              [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
              ; input_field
                  ~label_text:"Email"
                  ~name:"email"
                  ~input_type:`Email
                  ~placeholder:"Enter your email"
                  ~required:true
                  ()
              ; input_field
                  ~label_text:"Password"
                  ~name:"password"
                  ~input_type:`Password
                  ~placeholder:"Enter your password"
                  ~required:true
                  ()
              ; button
                  ~a:[ a_button_type `Submit; a_class [ "btn"; "w-full" ] ]
                  [ txt "Login" ]
              ]
          ; p
              ~a:[ a_class [ "mt-4"; "text-center"; "text-sm"; "text-gray-400" ] ]
              [ txt "Don't have an account? "
              ; a
                  ~a:
                    [ a_href "/register"; a_class [ "text-blue-400"; "hover:underline" ] ]
                  [ txt "Register" ]
              ]
          ]
      ]
  in
  Layout.layout nav content
;;

let register_page ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ~csrf () in
  let error_msg =
    match error with
    | Some msg -> div ~a:[ a_class [ "text-red-500"; "mb-4"; "text-center" ] ] [ txt msg ]
    | None -> div []
  in
  let content =
    div
      ~a:[ a_class [ "max-w-md"; "mx-auto" ] ]
      [ h2 ~a:[ a_class [ "3xl"; "font-bold"; "mb-6"; "text-center" ] ] [ txt "Register" ]
      ; error_msg
      ; div
          ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-6" ] ]
          [ form
              ~a:[ a_method `Post; a_action "/register" ]
              [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
              ; input_field
                  ~label_text:"Email"
                  ~name:"email"
                  ~input_type:`Email
                  ~placeholder:"Enter your email"
                  ~required:true
                  ()
              ; input_field
                  ~label_text:"Nickname"
                  ~name:"nickname"
                  ~input_type:`Text
                  ~placeholder:"Choose a nickname"
                  ~required:true
                  ()
              ; input_field
                  ~label_text:"Password"
                  ~name:"password"
                  ~input_type:`Password
                  ~placeholder:"Choose a password"
                  ~required:true
                  ()
              ; input_field
                  ~label_text:"Confirm Password"
                  ~name:"confirm_password"
                  ~input_type:`Password
                  ~placeholder:"Confirm your password"
                  ~required:true
                  ()
              ; button
                  ~a:[ a_button_type `Submit; a_class [ "btn"; "w-full" ] ]
                  [ txt "Register" ]
              ]
          ; p
              ~a:[ a_class [ "mt-4"; "text-center"; "text-sm"; "text-gray-400" ] ]
              [ txt "Already have an account? "
              ; a
                  ~a:[ a_href "/login"; a_class [ "text-blue-400"; "hover:underline" ] ]
                  [ txt "Login" ]
              ]
          ]
      ]
  in
  Layout.layout nav content
;;
