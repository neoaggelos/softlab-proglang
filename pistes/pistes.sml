(* pistes.sml *)

(* a 'round is a (stars, [sorted list of keys needed], [sorted list of keys given])) *)
(* a 'state is a (stars, [sorted list of keys we have], [sorted list of what we have not played])) *)

(* all lists are kept sorted, otherwise it all goes to shit *)
fun pistes(fname : string) =
  let
    fun list_remove_all([], [] : int list) = (true, [])
      | list_remove_all([], x::xs) = (false, [])
      | list_remove_all(y::ys, []) = (true, y::ys)
      | list_remove_all(y::ys, x::xs) =
        if x = y then list_remove_all(ys, xs) else
        let
          val (b, v) = list_remove_all(ys, x::xs)
        in
          (b, y::v)
        end

    fun list_add_sorted([], x) = [x]
      | list_add_sorted(y::ys, x) = if x < y then x::y::ys else y::list_add_sorted(ys, x)

    fun list_add_all_sorted(dest, []) = dest
      | list_add_all_sorted(dest, x::xs) = list_add_all_sorted(list_add_sorted(dest, x), xs)

    fun list_contains([], a : (int * int list * int list)) = false
      | list_contains(x::xs, a) = if x = a then true else list_contains(xs, a)

    fun load_data(fname : string) =
      let
        val fin = TextIO.openIn fname

        fun read_int (fin) =
          Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) fin)

        fun read_ints(list, 0, fin) = list
          | read_ints(list, n, fin) = read_ints(list_add_sorted(list, read_int (fin)), n-1, fin)

        val N = read_int(fin)
        val rounds = Array.array(N+1, (0, [], []))

        fun read_rounds(array, current) = 
        let
          val num_keys_needed = read_int(fin)
          val num_keys_given = read_int(fin)
          val stars = read_int(fin)
          val needs = read_ints([], num_keys_needed, fin)
          val gives = read_ints([], num_keys_given, fin)
        in
          (Array.update(array, current, (stars, needs, gives));
          if current < N then read_rounds(array, current+1) else ())
        end
      in
        read_rounds(rounds, 0);
        (N, rounds)
      end

    fun range(a, b) =
      if a = b then [b] else (a :: range(a+1, b))

    fun find_new_states([], keys, stars, rounds, states, olds, all_notplayed) = states
      | find_new_states(n::np, keys, stars, rounds, states , olds, all_notplayed) =
      let
        val (r_stars, r_needs, r_gives) = Array.sub(rounds, n)
        val (success, new_keys) = list_remove_all(keys, r_needs)
      in
        if success then let
          val new_keys = list_add_all_sorted(new_keys, r_gives)
          val new_stars = stars + r_stars
          val (_, new_notplayed) = list_remove_all(all_notplayed, [n])

          val s = (new_stars, new_keys, new_notplayed)
          val check = list_contains(states, s) orelse list_contains(olds, s)

          val new_states = if check then states else s::states
          in
            find_new_states(np, keys, stars, rounds, new_states, olds, all_notplayed)
          end
        else
          find_new_states(np, keys, stars, rounds, states, olds, all_notplayed)
      end

    fun hardwork(rounds, [], old_states, max) = max
      | hardwork(rounds, (stars, keys, notplayed)::states, old_states, max) =
      let
        val new_states = find_new_states(notplayed, keys, stars, rounds, states, old_states, notplayed)
        val new_max = if max > stars then max else stars
      in
        hardwork(rounds, new_states, (stars, keys, notplayed)::old_states, new_max)
      end

    (* it all comes down to this *)
    val (N, rounds) = load_data(fname)
    val states = [(0, [], range(0,N))]

    val max = hardwork(rounds, states, [], 0)
  in
    print(Int.toString(max) ^ "\n")
  end

(* bye ML *)