(lang dune 3.20)

(name asoiafdle)

(generate_opam_files true)

(source
 (github FelixTCP/asoiafdle))

(authors "Felix <author@example.com>")

(maintainers "Felix <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name asoiafdle)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  dream
  caqti
  caqti-lwt
  caqti-lwt-unix
  caqti-driver-sqlite3
  ppx_rapper
  safepass
  yojson
  ppx_yojson_conv
  lwt
  lwt_ppx
  tyxml)
 (tags
  ("asoiaf" "wordle" "game" "htmx" "dream")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
