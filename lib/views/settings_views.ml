let settings_page ?user ?success ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ?user ~csrf () in
  let success_msg =
    match success with
    | Some msg -> Printf.sprintf "<div class='text-green-500 mb-4'>%s</div>" msg
    | None -> ""
  in
  let error_msg =
    match error with
    | Some msg -> Printf.sprintf "<div class='text-red-500 mb-4'>%s</div>" msg
    | None -> ""
  in
  match user with
  | None ->
    Layout.layout
      nav
      {|
      <div class="max-w-md mx-auto text-center">
        <p>Please <a href="/login" class="text-blue-400 hover:underline">login</a> to access settings.</p>
      </div>
    |}
  | Some u ->
    Layout.layout
      nav
      (Printf.sprintf
         {|
    <div class="w-full max-w-2xl mx-auto">
      <h2 class="text-3xl font-bold mb-6">Account Settings</h2>
      %s
      %s
      
      <div class="bg-slate-800 rounded-lg p-6">
        <p class="text-sm text-gray-400 mb-6">Update one or more fields below. Only current password is required.</p>
        <form method="POST" action="/settings/update">
          <input type="hidden" name="dream.csrf" value="%s">
          
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">New Email</label>
            <p class="text-xs text-gray-500 mb-1">Current: <span class="text-asoiaf-gold">%s</span></p>
            <input type="email" name="email" class="input w-full" placeholder="Leave empty to keep current">
          </div>
          
          <hr class="border-slate-700 my-6">
          
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">New Nickname</label>
            <p class="text-xs text-gray-500 mb-1">Current: <span class="text-asoiaf-gold">%s</span></p>
            <input type="text" name="nickname" class="input w-full" placeholder="Leave empty to keep current">
          </div>
          
          <hr class="border-slate-700 my-6">
          
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">New Password</label>
            <input type="password" name="new_password" class="input w-full mb-2" placeholder="Leave empty to keep current">
            <label class="block text-sm font-medium mb-1">Confirm New Password</label>
            <input type="password" name="confirm_password" class="input w-full" placeholder="Confirm new password">
          </div>
          
          <hr class="border-slate-700 my-6">
          
          <div class="mb-6">
            <label class="block text-sm font-medium mb-1">Current Password <span class="text-red-400">*</span></label>
            <input type="password" name="current_password" class="input w-full" required>
          </div>
          
          <button type="submit" class="btn w-full">Update</button>
        </form>
      </div>
    </div>
  |}
         success_msg
         error_msg
         csrf
         u.Models.email
         u.Models.nickname)
;;
