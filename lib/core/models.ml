(* Models *)
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type user =
  { id : int
  ; email : string
  ; password_hash : string
  ; nickname : string
  ; friend_code : string
  ; created_at : string
  }
[@@deriving yojson]

type character =
  { name : string
  ; allegience : string
  ; region : string
  ; gender : string
  ; status : string
  ; first_appearance : string
  ; title : string
  ; age_bracket : string
  ; last_seen : string
  }
[@@deriving yojson]
