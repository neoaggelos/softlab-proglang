
agora(File, When, Missing) :-
    myread_input(File, Freqs),
    listlcm(Freqs, Lcm2r),
    reverse(Freqs, Reved),
    listlcm(Reved, Lcm2lrev),
    reverse(Lcm2lrev, Lcm2l),
    villagelcms(Lcm2r, Lcm2l, Lcms),
    [WholeLcm|_] = Lcm2r,	
    findmin(Lcms, 1, When, Missing, WholeLcm, 0).
    

%reading_files___________________________
myread_input(File, Freqs) :-
    	open(File, read, Stream),
    	read_line_to_codes(Stream, Line),
    	atom_codes(Atom, Line),
    	atom_number(Atom, _),
    	read_line(Stream, Freqs).


read_line(Stream, Freq) :-
    	read_line_to_codes(Stream, Line),
    	atom_codes(Atom, Line),
    	atomic_list_concat(Freqs, ' ', Atom),
    	maplist(atom_number, Freqs, Freq).
%end_of_file_reading_code________________


listlcm(List, Lcm2r) :- listlcmhelper(List, Lcm2r,[],1).

listlcmhelper([],Lcm2r,Acc,_) :- Lcm2r = Acc. 	% ιδιο με helper([],A,A,_) 

listlcmhelper([Head|Tail], Lcm2r, Acc, Lcmsofar) :- 
    gcd(Head, Lcmsofar, GCD), 
    CurLcm is Lcmsofar * Head / GCD,
    NewAcc = [CurLcm | Acc],	% το τελικό αποτέλεσμα θα είναι ανεστραμμένο [ν-οστο χωριο <- 1ο χωριο]
                    % (φυσικα για τον υπολογισμο των εκπ απο 1 ως ν
                    % αλλιως παει απο 1ο στο ν-οστο και το αποτελεσμα θελει rev για να 
                    % το ελεγξουμε)
    listlcmhelper(Tail, Lcm2r, NewAcc, CurLcm).

gcd(A,B,Res) :- (A = B -> Res is A; A > B -> fgcd(A,B,Res) ; fgcd(B,A,Res)).

fgcd(A,0,A) :- !.
fgcd(A,B,Res) :- NewA is A mod B, fgcd(B,NewA,Res).

villagelcms([_|Tail2r], Lcm2l, Lcms) :-
    [Head2r2|Tail2r2] = Tail2r,	% πεταω τα πρωτα 2 στοιχεια απο το Lcm2r
    Acc = [Head2r2],		% το πρωτο εκπ (αν λειπει ο ν-οστος) ειναι το εκπ ως το ν-1
    villagehelper(Tail2r2, Lcm2l, Lcms, Acc).	% πρεπει να εχω υποψην μου οτι ο Tail2l ειναι μεγαλυτερος
                            % οταν φτιαχνω τον helper

villagehelper([], [Head|_], Lcms, Acc) :- Lcms = [Head|Acc], !. 	% σταματαω backtracking
% οταν αδειασει ο lcm2r, θα εχω μεινει με τα εκπ για 2 και 1 απο δεξια
% αρα χρειαζομαι μονο το 2, δηλαδη αν λειπει μονο ο 1ο, Θετω το αποτελεσμα

villagehelper([Head2r|Tail2r], [Head2l|Tail2l], Lcms, Acc) :-
    % θα βαλω στο head του acc την τιμη lcm2r(i-1) * lcm2l(i+1) / gcd -> το εκπ αν λειπει ο i
    gcd(Head2r, Head2l, GCD),
    Imissing is Head2r * Head2l / GCD,
    NewAcc = [Imissing | Acc],
    villagehelper(Tail2r, Tail2l, Lcms, NewAcc).

% Πρεπει τελος να βρω το ελαχιστο και την θεση του
% Πρεπει να υποθεσω πως το λεαχιστο ειναι το συνολικο εκπ 
% (μιας και δεν εμφανιζεται πουθενα στην λιστα μου)
% και η αρχικη θεση 0 (δεν λειπει κανενας)
% και να ψαξω με αυστηρη ανισωση για νεο Min

findmin([], _, Min, Pos, Min, Pos) :- !. 		%stop_backtracking
findmin([Head|Tail], Cnt, Min, Pos, AprioriMin, AprioriPos) :-
    ( Head < AprioriMin -> AposterioriMin is Head, AposterioriPos = Cnt 
    ; AposterioriMin is AprioriMin, AposterioriPos = AprioriPos),
    NewCnt is Cnt + 1,
    findmin(Tail, NewCnt, Min, Pos, AposterioriMin, AposterioriPos). 