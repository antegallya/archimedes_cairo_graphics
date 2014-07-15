Build and use of the custom backend in Archimedes
=================================================
You have two options to use a custom backend in Archimedes:

1. Build the backend as a plugin:
---------------------------------
With ocamlbuild it looks like:

   `ocamlbuild -use-ocamlfind -pkgs archimedes.cairo,graphics
    archimedes_cairo_graphics.cmxs`

and make your code find it, for example:

    let vp = A.init ~dirs:["./_build"] ["Cairo_graphics"] in [...]

2. Build it with your application:
---------------------------------
Compile your main program:

   `ocamlbuild -use-ocamlfind -pkgs archimedes.cairo,graphics main.native`

but you have to force a dependency to the backend module. For example :

    module ForLinking__ = Archimedes_cairo_graphics

    let () =
      let vp = A.init ["Cairo_graphics"] in [...]
