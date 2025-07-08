(lang dune 3.0)

(name pgocaml)

(generate_opam_files)

(source
 (github darioteixeira/pgocaml))

(license "LGPL-2.0-only with OCaml-LGPL-linking-exception")

(authors "Richard W.M. Jones" "Dario Teixeira")

(maintainers "dario.teixeira@nleyten.com" "raoul.hidalgo.charman@gmail.com")

(version 4.4.0)

(package
 (name pgocaml)
 (synopsis "Native OCaml interface to PostgreSQL databases")
 (description
  "PGOCaml provides an interface to PostgreSQL databases for OCaml applications.\nNote that it speaks the PostgreSQL wire protocol directly, and therefore does\nnot need to create bindings to the PostgreSQL libpq C library.\nThe PPX syntax extension is now packaged separately as 'pgocaml_ppx'.\nYou will want to take a look at it if you're considering using PGOCaml.\n")
 (depends
  (calendar
   (>= 2.0))
  camlp-streams
  csv
  (dune
   (>= 1.10))
  hex
  (ocaml
   (>= 4.07))
  ppx_sexp_conv
  (re
   (>= 1.5.0))
  (ppx_deriving
   (>= 4.2))
  rresult
  sexplib
  ppx_optcomp
  (result :with-test)
  (ounit :with-test)))

(package
 (name pgocaml_ppx)
 (synopsis "PPX extension for PGOCaml")
 (description
  "PGOCaml provides an interface to PostgreSQL databases for OCaml applications.\nThis PPX syntax extension enables one to directly embed SQL statements inside\nthe OCaml code. The extension uses the 'describe' feature of PostgreSQL to\nobtain type information about the database. This allows PGOCaml to check at\ncompile-time if the program is indeed consistent with the database structure.\n")
 (depends
  pgocaml
  ppxlib
  ppx_optcomp
  (ounit :with-test)))
