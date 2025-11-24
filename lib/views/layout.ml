let version = "v0.1.0"

let footer () =
  Printf.sprintf
    {|
  <footer class="bg-slate-800 border-t border-slate-700 px-4 py-4 mt-auto">
    <div class="max-w-6xl mx-auto">
      <div class="flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-slate-400">
        <div class="flex items-center gap-2">
          <span>Version %s | made with <span class="text-red-500">💙</span> by <a href="https://github.com/FelixTCP" target="_blank" rel="noopener noreferrer" class="hover:text-asoiaf-gold transition-colors">FelixTCP</a>
          </span>
        </div>
        <div class="flex items-center gap-2">
          <span>All characters &copy; George R. R. Martin</span>
        </div>
        <div class="flex items-center gap-2">
          <a 
            href="https://github.com/FelixTCP/asoiafdle" 
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center gap-2 px-3 py-1.5 bg-slate-700 hover:bg-slate-600 rounded-md transition-colors"
          >
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path fill-rule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clip-rule="evenodd"/>
            </svg>
            <span>View on GitHub</span>
          </a>
        </div>
      </div>
    </div>
  </footer>
|}
    version
;;

let navbar ?user ~csrf () =
  let auth_section =
    match user with
    | Some _u ->
      Printf.sprintf
        {|
        <a href="/settings" class="hover:text-asoiaf-gold transition-colors">Settings</a>
        <form method="POST" action="/logout" class="inline">
          <input type="hidden" name="dream.csrf" value="%s">
          <button type="submit" class="hover:text-asoiaf-gold transition-colors">Logout</button>
        </form>
      |}
        csrf
    | None ->
      {|<a href="/login" class="hover:text-asoiaf-gold transition-colors">Login</a>|}
  in
  Printf.sprintf
    {|
  <nav class="bg-slate-800 border-b border-slate-700 px-4 py-3">
    <div class="max-w-6xl mx-auto flex justify-between items-center">
      <a href="/" class="text-xl md:text-2xl font-bold text-asoiaf-gold hover:text-yellow-400">ASOIAFDLE</a>
      <div class="flex gap-4 items-center">
        <a href="/leaderboard" class="hover:text-asoiaf-gold transition-colors">Leaderboard</a>
        %s
      </div>
    </div>
  </nav>
|}
    auth_section
;;

let layout navbar body =
  Printf.sprintf
    {|
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ASOIAFDLE</title>
  <link href="/static/output.css" rel="stylesheet">
  <script src="https://unpkg.com/htmx.org@1.9.10"></script>
</head>
<body class="h-full flex flex-col bg-gradient-to-b from-slate-900 to-slate-800 text-white">
  %s
  <main class="flex-1 p-4 md:p-6">
    %s
  </main>
  %s
</body>
</html>
|}
    navbar
    body
    (footer ())
;;
