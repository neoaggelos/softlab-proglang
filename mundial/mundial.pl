%_________________reading_input_____________________


read_input(File, N, Teams) :-

    open(File, read, Stream),

    read_line_to_codes(Stream, Line),

    atom_codes(Atom, Line),
    
    atom_number(Atom, N),

    read_lines(Stream, N, Teams).



read_lines(Stream, N, Teams) :-
    
    ( N == 0 -> Teams = []
    ; 
      N > 0  -> read_line(Stream, Team),

      Nm1 is N-1,

      read_lines(Stream, Nm1, RestTeams),

      Teams = [Team | RestTeams]).



read_line(Stream, team(Name, P, A, B)) :-

    read_line_to_codes(Stream, Line),

    atom_codes(Atom, Line),

    atomic_list_concat([Name | Atoms], ' ', Atom),

    maplist(atom_number, Atoms, [P, A, B]).


%___________________________________________________



mundial(File, Matches) :-

    read_input(File, _, Teams),

    solve(Teams, Matches).




solve(Teams, Matches) :-
    solve_aux(Teams, Matches, []).




solve_aux([], Matches, Matches) :- !.


solve_aux(Teams, Matches, Acc) :-
 
    split_losers_and_winners(Teams, Winners, Losers),

    matchups(Losers, Winners, RoundMatchups, QualifiedTeams),

    append(Acc, RoundMatchups, NewAcc),

    solve_aux(QualifiedTeams, Matches, NewAcc).





%____________tail_recursive_splits_winners_and_losers_based_on_their_remaining_rounds__________________
split_losers_and_winners(Teams, Winnerz, Loserz) :- winners_and_losers(Teams, Winnerz, Loserz, [], []).



winners_and_losers([], Winnerz, Loserz, Winnerz, Loserz).


winners_and_losers([team(Team, R, GF, GA) | Teams], Winnerz, Loserz, WinnerAcc, LoserAcc) :-

    ( R == 1 ->
    
  winners_and_losers(Teams, Winnerz, Loserz, WinnerAcc, [team(Team, 1, GF, GA) | LoserAcc])

    ; winners_and_losers(Teams, Winnerz, Loserz, [team(Team, R, GF, GA) | WinnerAcc], LoserAcc) ).




%______________________explores_current_possible_matchups_not_tail_recursive_________________________________

matchups([], [], [], [], _) :- !.


matchups([team(Finalist1, _, GF, GA), team(Finalist2, _, GA, GF)], [], [match(Finalist1, Finalist2, GF, GA)], [], _) :- !.

matchups(Losers, Winners, RoundMatches, QualifiedTeams) :-
    select(team(Winner, Round, GoalsForW, GoalsAgainstW), Winners, RestWinners),
    select(team(Loser, _, GoalsForL, GoalsAgainstL), Losers, RestLosers),
    ( (GoalsForL =< GoalsAgainstW, GoalsAgainstL =< GoalsForW ) ->
      GolasosFor is GoalsForW - GoalsAgainstL,

      GolasosAgainst is GoalsAgainstW - GoalsForL,

          matchups(RestLosers, RestWinners, RestMatches, RestQualifiedTeams),

      RoundMatches = [match(Winner, Loser, GoalsAgainstL, GoalsForL) | RestMatches],

      NextRound is Round - 1,

      QualifiedTeams = [team(Winner, NextRound, GolasosFor, GolasosAgainst) | RestQualifiedTeams] ).

%_______not_important________

log2(1,0) :- !.

log2(N,Ans) :-

    	Next is N/2,

    	log2(Next, A),

    	Ans is A + 1.

%____________________________        