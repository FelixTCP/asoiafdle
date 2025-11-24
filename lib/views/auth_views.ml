let login_page ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ~csrf () in
  let error_msg =
    match error with
    | Some msg -> Printf.sprintf "<div class='text-red-500 mb-4'>%s</div>" msg
    | None -> ""
  in
  Layout.layout
    nav
    (Printf.sprintf
       {|
    <div class="w-full max-w-md mx-auto">
      <h2 class="text-2xl font-bold mb-6">Login</h2>
      %s
      <form method="POST" action="/login">
        <input type="hidden" name="dream.csrf" value="%s">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">Email</label>
          <input type="email" name="email" class="input w-full" required>
        </div>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1">Password</label>
          <input type="password" name="password" class="input w-full" required>
        </div>
        <button type="submit" class="btn w-full">Login</button>
      </form>
      <p class="mt-4 text-center text-sm">
        Don't have an account? <a href="/register" class="text-blue-400 hover:underline">Register</a>
      </p>
    </div>
  |}
       error_msg
       csrf)
;;

let register_page ?error request =
  let csrf = Dream.csrf_token request in
  let nav = Layout.navbar ~csrf () in
  let error_msg =
    match error with
    | Some msg -> Printf.sprintf "<div class='text-red-500 mb-4'>%s</div>" msg
    | None -> ""
  in
  Layout.layout
    nav
    (Printf.sprintf
       {|
    <div class="w-full max-w-md mx-auto">
      <h2 class="text-2xl font-bold mb-6">Register</h2>
      %s
      <form method="POST" action="/register">
        <input type="hidden" name="dream.csrf" value="%s">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">Email</label>
          <input type="email" name="email" class="input w-full" required>
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">Nickname</label>
          <input type="text" name="nickname" class="input w-full" required>
        </div>
        <div class="mb-6">
          <label class="block text-sm font-medium mb-1">Password</label>
          <input type="password" name="password" class="input w-full" required>
        </div>
        <button type="submit" class="btn w-full">Register</button>
      </form>
      <p class="mt-4 text-center text-sm">
        Already have an account? <a href="/login" class="text-blue-400 hover:underline">Login</a>
      </p>
    </div>
  |}
       error_msg
       csrf)
;;
