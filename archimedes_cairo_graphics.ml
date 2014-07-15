(* File: archimedes_cairo_graphics.ml

   Copyright (C) 2014

     Pierre Hauweele <Pierre@Hauweele.net>

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License version 3 or
   later as published by the Free Software Foundation, with the special
   exception on linking described in the file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details. *)

(** Cairo_graphics Archimedes plugin *)

open Bigarray
open Printf

module A = Archimedes
module C = Cairo
module AC = Archimedes_cairo

let round x = truncate(if x < 0. then x -. 0.5 else x +. 0.5)

module B =
struct

  include Archimedes_cairo.B

  let name = "cairo_graphics"

  let ofsw = ref 0.
  and ofsh = ref 0.

  let get_cairo_context t =
    (Obj.magic t :> C.context)

  let show t =
    AC.B.show t;
    let cr = get_cairo_context t in
    let surf = C.get_target cr in
    let w = C.Image.get_width surf
    and h = C.Image.get_height surf
    and data32 = C.Image.get_data32 surf in
    let data_img =
      Array.init h
        (fun y -> Array.init w (fun x ->
           let c = data32.{y, x} in
           let c = Int32.logand 0x00FFFFFFl c in
           Int32.to_int c))
    in
    Graphics.draw_image (Graphics.make_image data_img) 0 0;
    Graphics.synchronize ()

  let make ~options:_ width height =
    let t = AC.B.make ~options:[] width height in
    Graphics.open_graph (
        sprintf " %ix%i" (round (width +. !ofsw)) (round (height +. !ofsh)));
    Graphics.set_window_title "Archimedes";
    Graphics.auto_synchronize false;
    t

  let close ~options:_ t =
    show t;
    AC.B.close ~options:[] t;
    Graphics.set_window_title "Archimedes [Press a key to close]";
    ignore(Graphics.wait_next_event [Graphics.Key_pressed]);
    Graphics.close_graph()

end

let () =
  let module U = A.Backend.Register(B) in
  if Sys.os_type = "Win32" then (
    (* Set offsets so the actual surface is of the requested size. *)
    Graphics.open_graph " 100x100";
    let w = Graphics.size_x ()
    and h = Graphics.size_y() in
    Graphics.close_graph ();
    (* [abs] instead of [max 0], justified experimenting with M$ Windows *)
    B.ofsw := float (abs(100 - w));
    B.ofsh := float (100 - h);
  )
