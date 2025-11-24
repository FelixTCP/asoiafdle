let hash_password (password : string) : string Lwt.t =
  Lwt.return (Bcrypt.hash password |> Bcrypt.string_of_hash)
;;

let verify_password (password : string) (hash : string) : bool Lwt.t =
  try
    let h = Bcrypt.hash_of_string hash in
    Lwt.return (Bcrypt.verify password h)
  with
  | _ -> Lwt.return false
;;
