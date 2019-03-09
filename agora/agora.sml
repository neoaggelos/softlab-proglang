(* agora.sml *)


fun agora( fname : string ) = let
  fun gcd (a : IntInf.int,0) = a
        | gcd (a, b) = gcd (b,a mod b)

  fun lcm(a : IntInf.int, b) = a div gcd(a,b) * b

  fun reverse [] = []
    | reverse li = let
      fun help (nil,l) = l
        | help (x::xs, l) = help (xs ,x::l);
    in
        help(li, nil)
    end

  fun min(x : IntInf.int, y) = if x < y then x else y

  val fin = TextIO.openIn fname
  fun read_next_int fin =
    Option.valOf (TextIO.scanStream (IntInf.scan StringCvt.DEC) fin)

  fun read_ints (fin, 0 : IntInf.int) = []
    | read_ints (fin, n) = (read_next_int fin) :: read_ints(fin, n-1)

  val count = read_next_int fin

  val l = read_ints(fin, count)

  fun calc_lcms ([], prev : IntInf.int) = []
    | calc_lcms (x::xs, prev) = let
        val y = lcm(x, prev)
      in
        y :: calc_lcms(xs,y)
    end

  val right = calc_lcms(l,1 : IntInf.int)
  val left = reverse(calc_lcms(reverse(l), 1 : IntInf.int))

  val lcms_first = [List.nth(left, 1)] (*[hd (tl left)]*)
  val lcms_last = [List.nth(right, LargeInt.toInt(count-1))] (*[hd (tl (reverse(right)))]*)
  
  fun get_lcms([], nonexistingcasebutihatewarnings) = []
    | get_lcms(right, []) = []
    | get_lcms(r::rs, l::ls) = lcm(r, l) :: get_lcms(rs, ls)

  val lcms_without = lcms_first @ get_lcms(right, tl(tl left)) @ lcms_last

  fun min list =
    let
      fun help ([],m:IntInf.int, index, saved) = (m, saved)
        | help (x::xs,m, index, saved) = if x < m then help (xs, x, index+1, index) else help (xs,m, index+1, saved)
    in
      help (list, hd list, 0, 0)
    end

  val (result, result_pos) = min (lcms_without)
  val pos = if result mod List.nth(l, result_pos) = 0 then 0 else result_pos+1
in
  print(IntInf.toString(result) ^ " " ^ Int.toString(pos) ^ "\n")
end;