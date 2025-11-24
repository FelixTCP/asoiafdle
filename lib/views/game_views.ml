let index_page ?user ?(guesses = "") ~csrf ~game_complete () =
  let nav = Layout.navbar ?user ~csrf () in
  let welcome_msg =
    match user with
    | Some _ -> ""
    | None ->
      Printf.sprintf
        {|
      <p class='text-center mb-4'>
        <a href='/login' class='text-blue-400 hover:underline'>Login</a> or 
        <a href='/register' class='text-blue-400 hover:underline'>Register</a> to save your progress!
      </p>
    |}
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
      {|
      <div class="bg-blue-900 border border-blue-500 rounded-lg p-4 mb-4">
        <p class="text-center text-lg">Game complete! Come back tomorrow for a new character.</p>
      </div>
    |}
    else
      Printf.sprintf
        {|
      <div class="mb-4 text-sm text-gray-400">
        <p>Guess the character based on their attributes!</p>
        <p>You have 6 guesses. Good luck!</p>
      </div>
      <script>
        const ALL_CHARACTERS = %s;
      </script>
      <form hx-post="/guess" hx-target="#results" hx-swap="beforeend" class="mb-8" hx-on::after-request="if(event.detail.target.id === 'results') { this.reset(); document.getElementById('characters').innerHTML = ''; }">
        <input type="hidden" name="dream.csrf" value="%s">
        <input 
          type="text" 
          name="guess" 
          id="guess-input"
          placeholder="Start typing character name..." 
          class="input w-full max-w-md mb-4" 
          list="characters"
          autocomplete="off"
          oninput="
            const val = this.value.toLowerCase();
            const datalist = document.getElementById('characters');
            datalist.innerHTML = '';
            if (val.length >= 3) {
              const matches = ALL_CHARACTERS.filter(c => c.toLowerCase().includes(val));
              matches.forEach(c => {
                const option = document.createElement('option');
                option.value = c;
                datalist.appendChild(option);
              });
            }
          "
          onkeydown="
            if (event.key === 'Tab' || event.key === 'Enter') {
              const val = this.value.toLowerCase();
              if (val.length < 3) return;
              const options = document.getElementById('characters').options;
              if (options.length > 0) {
                 this.value = options[0].value;
                 if (event.key === 'Tab') event.preventDefault();
              }
            }
          "
          required>
        <datalist id="characters"></datalist>
        <button type="submit" class="btn">Guess</button>
      </form>
    |}
        all_characters_json
        csrf
  in
  Layout.layout
    nav
    (Printf.sprintf
       {|
    <div class="max-w-6xl mx-auto text-center">
      <h2 class="text-3xl font-bold mb-6">Guess the Character</h2>
      %s
      <div id="game-container" class="overflow-x-auto">
        <div class="min-w-[600px]">
          %s
          <div class="grid grid-cols-9 gap-2 text-center text-[10px] md:text-sm mb-2 font-bold">
            <div class="p-2">Name</div>
            <div class="p-2">Allegience</div>
            <div class="p-2">Region</div>
            <div class="p-2">Gender</div>
            <div class="p-2">Status</div>
            <div class="p-2">First Appearance</div>
            <div class="p-2">Title</div>
            <div class="p-2">Age</div>
            <div class="p-2">Last Seen</div>
          </div>
          <div id="results" class="space-y-2">
            %s
          </div>
        </div>
      </div>
    </div>
  |}
       welcome_msg
       form_section
       guesses)
;;

let guess_result (c : Models.character) (r : Game.guess_result) =
  let status_class s =
    match s with
    | Game.Correct -> "bg-green-600"
    | Game.Incorrect -> "bg-red-600"
  in
  Printf.sprintf
    {|
    <div class="grid grid-cols-9 gap-2 text-center text-[10px] md:text-sm mb-2">
      <div class="p-2 rounded flex items-center justify-center min-h-[3rem]"><span class="font-bold text-asoiaf-gold">%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
      <div class="p-2 rounded %s flex items-center justify-center min-h-[3rem]"><span>%s</span></div>
    </div>
  |}
    c.name
    (status_class r.allegience)
    c.allegience
    (status_class r.region)
    c.region
    (status_class r.gender)
    c.gender
    (status_class r.status)
    c.status
    (status_class r.first_appearance)
    c.first_appearance
    (status_class r.title)
    c.title
    (status_class r.age_bracket)
    c.age_bracket
    (status_class r.last_seen)
    c.last_seen
;;
