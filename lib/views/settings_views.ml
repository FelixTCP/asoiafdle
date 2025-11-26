open Tyxml.Html

let input_field
      ?(label_text = "")
      ?(sub_text = "")
      ~name
      ~input_type
      ~placeholder
      ?(required = false)
      ?(value = "")
      ()
  =
  let label_el =
    if label_text <> ""
    then
      label
        ~a:[ a_class [ "block"; "text-sm"; "font-medium"; "mb-1" ] ]
        [ txt label_text
        ; (if required
           then span ~a:[ a_class [ "text-red-400" ] ] [ txt " *" ]
           else txt "")
        ]
    else div []
  in
  let sub_el =
    if sub_text <> ""
    then p ~a:[ a_class [ "text-xs"; "text-gray-500"; "mb-1" ] ] [ Unsafe.data sub_text ]
    else div []
  in
  let input_attribs =
    [ a_input_type input_type
    ; a_name name
    ; a_class [ "input"; "w-full" ]
    ; a_placeholder placeholder
    ]
    @ (if required then [ a_required () ] else [])
    @ if value <> "" then [ a_value value ] else []
  in
  div ~a:[ a_class [ "mb-4" ] ] [ label_el; sub_el; input ~a:input_attribs () ]
;;

let settings_page ?user ?success ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ?user ~csrf () in
  let success_msg =
    match success with
    | Some msg -> div ~a:[ a_class [ "text-green-500"; "mb-4" ] ] [ txt msg ]
    | None -> div []
  in
  let error_msg =
    match error with
    | Some msg -> div ~a:[ a_class [ "text-red-500"; "mb-4" ] ] [ txt msg ]
    | None -> div []
  in
  match user with
  | None ->
    Layout.layout
      nav
      (div
         ~a:[ a_class [ "max-w-md"; "mx-auto"; "text-center" ] ]
         [ p
             [ txt "Please "
             ; a
                 ~a:[ a_href "/login"; a_class [ "text-blue-400"; "hover:underline" ] ]
                 [ txt "login" ]
             ; txt " to access settings."
             ]
         ])
  | Some u ->
    let content =
      div
        ~a:[ a_class [ "w-full"; "max-w-2xl"; "mx-auto" ] ]
        [ h2 ~a:[ a_class [ "text-3xl"; "font-bold"; "mb-6" ] ] [ txt "Account Settings" ]
        ; success_msg
        ; error_msg
        ; div
            ~a:[ a_class [ "bg-slate-800"; "rounded-lg"; "p-6" ] ]
            [ p
                ~a:[ a_class [ "text-sm"; "text-gray-400"; "mb-6" ] ]
                [ txt
                    "Update one or more fields below. Only current password is required."
                ]
            ; form
                ~a:[ a_method `Post; a_action "/settings/update" ]
                [ input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf ] ()
                ; input_field
                    ~label_text:"New Email"
                    ~sub_text:
                      (Printf.sprintf
                         "Current: <span class='text-asoiaf-gold'>%s</span>"
                         u.Models.email)
                    ~name:"email"
                    ~input_type:`Email
                    ~placeholder:"Leave empty to keep current"
                    ()
                ; hr ~a:[ a_class [ "border-slate-700"; "my-6" ] ] ()
                ; input_field
                    ~label_text:"New Nickname"
                    ~sub_text:
                      (Printf.sprintf
                         "Current: <span class='text-asoiaf-gold'>%s</span>"
                         u.Models.nickname)
                    ~name:"nickname"
                    ~input_type:`Text
                    ~placeholder:"Leave empty to keep current"
                    ()
                ; hr ~a:[ a_class [ "border-slate-700"; "my-6" ] ] ()
                ; div
                    ~a:[ a_class [ "mb-4" ] ]
                    [ input_field
                        ~label_text:"New Password"
                        ~name:"new_password"
                        ~input_type:`Password
                        ~placeholder:"Leave empty to keep current"
                        ()
                    ; input_field
                        ~label_text:"Confirm New Password"
                        ~name:"confirm_password"
                        ~input_type:`Password
                        ~placeholder:"Confirm new password"
                        ()
                    ]
                ; hr ~a:[ a_class [ "border-slate-700"; "my-6" ] ] ()
                ; input_field
                    ~label_text:"Current Password"
                    ~name:"current_password"
                    ~input_type:`Password
                    ~placeholder:""
                    ~required:true
                    ()
                ; button
                    ~a:[ a_button_type `Submit; a_class [ "btn"; "w-full" ] ]
                    [ txt "Update" ]
                ]
            ]
        ]
    in
    Layout.layout nav content
;;
