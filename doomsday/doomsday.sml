(* doomsday.sml *)

fun doomsday fname =
let
  fun read_file fname =
  let
    val a = (TextIO.inputAll (TextIO.openIn fname))
  in
    explode(a)
  end

  fun get_size tab =
  let
    fun find_first([], a, n) = ~1 (*ihatewarningsimnotangryyouareangry*) (*hiangryimdad*)
      | find_first(x::xs, a : char, n) = if x = a then n else find_first(xs, a,n+1)

    val M = find_first(tab, #"\n", 0)
    val N = (length tab) div M
  in
    (N,M)
  end

  val ch = read_file fname

  val (N, M) = get_size ch

  fun fill_initial_grid(grid, [], i, j, moves) = (grid, moves)
   |  fill_initial_grid(grid, c::cs, i, j, moves) =
        if c = #"\n" then
          fill_initial_grid(grid, cs, i+1,0, moves)
        else if c = #"X" then
          (Array2.update(grid, i, j, c);
          fill_initial_grid(grid, cs, i, j+1, moves))
        else if c = #"+" orelse c = #"-" then
          (Array2.update(grid, i, j, c);
          fill_initial_grid(grid, cs, i, j+1, (i, j, c, 0)::moves))
        else (* c == '.' *)
          fill_initial_grid(grid, cs, i, j+1, moves);

  val (grid, moves) = fill_initial_grid(Array2.array(N, M, #"."), ch, 0, 0, [])

  fun print_grid(grid, N, M, i, j) =
    (print(Char.toString(Array2.sub(grid, i, j)));
    if i = N-1 andalso j = M-1 then
      print("\n")
    else if j = M-1 then
      (print("\n"); print_grid(grid, N, M, i+1, 0))
    else
      print_grid(grid, N, M, i, j+1)
    )

  (*
  fun print_move(x,y,z,t) =
    print(Int.toString(x) ^ Int.toString(y) ^ Char.toString(z) ^ Int.toString(t) ^ "\n")
  *)
  
  fun list_hasnot([], x) = true
    | list_hasnot(l::ls, x : (int * int * char * int)) = if x = l then false else list_hasnot(ls, x) 

  (* does each next move repeatedly
    returns grid and the time when world died (or 0 if it did not die)
  *)
  fun do_next_move(grid, [], time) = (grid, time)
    | do_next_move(grid, (x,y,c,t)::ms, time) =
    let
      val u = Array2.sub(grid, x-1, y) handle Subscript => c
      val move_up = if (u <> c andalso u <> #"X" andalso u <> #"*") andalso list_hasnot(ms, (x-1, y, c,t+1)) then [(x-1, y, c, t+1)] else nil

      val d = Array2.sub(grid, x+1, y) handle Subscript => c
      val move_down = if (d <> c andalso d <> #"X" andalso d <> #"*") andalso list_hasnot(ms, (x+1, y, c, t+1)) then [(x+1, y, c, t+1)] else nil
      
      val l = Array2.sub(grid, x, y-1) handle Subscript => c
      val move_left = if (l <> c andalso l <> #"X" andalso l <> #"*") andalso list_hasnot(ms, (x, y-1, c, t+1)) then [(x, y-1, c, t+1)] else nil
      
      val r = Array2.sub(grid, x, y+1) handle Subscript => c
      val move_right = if (r <> c andalso r <> #"X" andalso r <> #"*") andalso list_hasnot(ms, (x, y+1, c, t+1)) then [(x, y+1, c, t+1)] else nil
      
      val new_moves = move_left @ move_right @ move_up @ move_down

      val old = Array2.sub(grid, x, y)
      val new_doomtime = if ((old = #"+" andalso c = #"-") orelse (old = #"-" andalso c = #"+"))
                            then t else time

      val new_character = 
        if (old = #"+" andalso c = #"-") orelse (old = #"-" andalso c = #"+")
          then #"*"
        else if old <> #"*"
          then c
        else
          old

    in
      ( (*print(Int.toString(length ms) ^ " more moves in queue\nWill add " ^ Int.toString(length new_moves) ^" more\nDoing move: "); print_move(x,y,c,t); print("Grid is: \n"); print_grid(grid,N,M,0,0); *)
      if (t > time andalso time > 0) then
        (grid, time)
      else if old = c then
        do_next_move(grid, ms @ new_moves, new_doomtime)
      else
        (Array2.update(grid, x,y, new_character);

        do_next_move(grid, ms @ new_moves, new_doomtime)))
    end

  val (final, time) = do_next_move(grid, moves, 0)

  val msg = if time = 0 then "the world is saved\n" else (Int.toString(time) ^ "\n")
in
  print(msg);
  print_grid(final, N,M,0,0)
end;