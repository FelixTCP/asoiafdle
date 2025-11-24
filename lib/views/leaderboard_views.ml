let leaderboard_page ?user ~global ~friends ~csrf () =
  let nav = Layout.navbar ?user ~csrf () in
  Layout.layout
    nav
    (Printf.sprintf
       {|
    <div class="max-w-6xl mx-auto">
      <h2 class="text-3xl font-bold mb-6">Leaderboards</h2>
      
      <div class="grid lg:grid-cols-2 gap-6">
        <div>
          <h3 class="text-2xl font-bold mb-4 text-asoiaf-gold">Global Leaderboard</h3>
          <div class="bg-slate-800 rounded-lg p-4 overflow-x-auto">
            <table class="w-full min-w-[500px]">
              <thead>
                <tr class="border-b border-slate-700">
                  <th class="text-left p-2">Player</th>
                  <th class="text-center p-2">Games</th>
                  <th class="text-center p-2">Wins</th>
                  <th class="text-center p-2" tooltip="Correct answers within first three guesses">Quick Wins</th>
                  <th class="text-center p-2">Avg Guesses</th>
                </tr>
              </thead>
              <tbody>
                %s
              </tbody>
            </table>
          </div>
        </div>
        
        <div>
          <h3 class="text-2xl font-bold mb-4 text-asoiaf-gold">Friends Leaderboard</h3>
          <div class="bg-slate-800 rounded-lg p-4 overflow-x-auto">
            %s
          </div>
        </div>
      </div>
      
      %s
    </div>
  |}
       (List.map
          (fun (nickname, games, wins, quick_wins, avg_guesses) ->
             Printf.sprintf
               "<tr><td class='p-2'>%s</td><td class='text-center p-2'>%d</td><td \
                class='text-center p-2'>%d</td><td class='text-center p-2'>%d</td><td \
                class='text-center p-2'>%.1f</td></tr>"
               nickname
               games
               wins
               quick_wins
               avg_guesses)
          global
        |> String.concat "")
       (if List.length friends > 0
        then
          "<table class='w-full min-w-[500px]'><thead><tr class='border-b \
           border-slate-700'><th class='text-left p-2'>Friend</th><th class='text-center \
           p-2'>Games</th><th class='text-center p-2'>Wins</th><th class='text-center \
           p-2'>Quick Wins</th><th class='text-center p-2'>Avg \
           Guesses</th></tr></thead><tbody>"
          ^ (List.map
               (fun (nickname, games, wins, quick_wins, avg_guesses) ->
                  Printf.sprintf
                    "<tr><td class='p-2'>%s</td><td class='text-center p-2'>%d</td><td \
                     class='text-center p-2'>%d</td><td class='text-center \
                     p-2'>%d</td><td class='text-center p-2'>%.1f</td></tr>"
                    nickname
                    games
                    wins
                    quick_wins
                    avg_guesses)
               friends
             |> String.concat "")
          ^ "</tbody></table>"
        else
          "<p class='text-gray-400'>No friends yet. Add friends to see their scores!</p>")
       (match user with
        | Some u ->
          Printf.sprintf
            {|
          <div class="mt-8 bg-slate-800 rounded-lg p-6">
            <h3 class="text-xl font-bold mb-4">Add Friend</h3>
            <div class="mb-4">
              <div class="flex items-center gap-2">
                <p class="text-sm text-gray-400">Your friend code:</p>
                <div class="relative inline-block">
                  <span id="friend-code" class="font-mono text-asoiaf-gold text-lg select-all">%s</span>
                  <div id="code-cover" class="absolute inset-0 bg-slate-600 rounded text-center text-gray-400" style="">
                    [ hidden ]
                  </div>
                </div>
                <button 
                  onclick="
                    const cover = document.getElementById('code-cover');
                    const btn = this;
                    if (cover.style.display === 'none') {
                      cover.style.display = '';
                      btn.textContent = '👁️‍🗨️';
                      btn.title = 'Reveal code';
                    } else {
                      cover.style.display = 'none';
                      btn.textContent = '👁️';
                      btn.title = 'Hide code';
                    }
                  "
                  class="px-3 py-1 bg-slate-700 hover:bg-slate-600 rounded transition-colors text-sm"
                  title="Reveal code"
                >👁️‍🗨️</button>
                <button 
                  onclick="
                    const code = '%s';
                    navigator.clipboard.writeText(code).then(() => {
                      const btn = this;
                      const originalText = btn.textContent;
                      btn.textContent = '✓ Copied!';
                      btn.classList.add('bg-green-600');
                      setTimeout(() => {
                        btn.textContent = originalText;
                        btn.classList.remove('bg-green-600');
                      }, 2000);
                    });
                  "
                  class="px-3 py-1 bg-slate-700 hover:bg-slate-600 rounded transition-colors text-sm"
                  title="Copy to clipboard"
                >📋 Copy</button>
              </div>
            </div>
            <form hx-post="/add-friend" hx-target="#friend-result" hx-swap="innerHTML" class="mt-4">
              <input type="hidden" name="dream.csrf" value="%s">
              <input type="text" name="friend_code" placeholder="Enter friend code..." class="input w-full max-w-md mb-2">
              <button type="submit" class="btn">Add Friend</button>
            </form>
            <div id="friend-result" class="mt-2"></div>
          </div>
        |}
            u.Models.friend_code
            u.Models.friend_code
            csrf
        | None ->
          "<p class='mt-8 text-center'><a href='/login' class='text-blue-400 \
           hover:underline'>Login</a> to add friends and compete!</p>"))
;;
