% Autor: Šimon Kadnár 
% Zadanie: Kostra grafu
% Login: xkadna00

start:-
    prompt(_, ''),
    read_lines(LL),
    split_lines(LL,Arr),

    remove_opposits(Arr, NotOpposits),
    remove_duplicates(NotOpposits, UniquePairs),

    exctract_tops(UniquePairs, Tops),
    length(Tops, Length),
    generate_combinations(UniquePairs, Length-1, R),

    print_noncycle(Tops, R).


%---------------------------------Vstup----------------------
%prebrane z https://moodle.vut.cz/pluginfile.php/848652/mod_resource/content/1/input2.pl

% ciatanie riadkov zo vstupu, konci na LF alebo EOF 
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).

% testuje znak na EOF alebo LF 
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).


% rozdeli riadok na podzoznamy 
split_line([],[]) :- !.
split_line([H1,_,H2| T], [(H1,H2)]) :- split_line(T, _).

% vstupom je zoznam riadkov (kazdy riadok je zoznam znakov) 
split_lines([],[]).
split_lines([L|Ls], T) :- split_line(L, H), split_lines(Ls, S1), append(H, S1, T).


%----------------------------Dupliakty-------------------

%Prediakt na odsstranenie opacnych dvojic
remove_opposits([], []).
remove_opposits([(A,B)|T], [(A,B)|R]) :-
    \+ member((B,A), T),
    remove_opposits(T, R).
remove_opposits([(A,B)|T], R) :-
    member((B,A), T),
    remove_opposits(T, R).

remove_duplicates([], []).
remove_duplicates([(A,B)|T], [(A,B)|R]) :-
    \+ member((A,B), T),
    remove_duplicates(T, R).
remove_duplicates([(A,B)|T], R) :-
    member((A,B), T),
    remove_duplicates(T, R).

%-----------------------------Vrcholy--------------------------------

%Predikat na ziskanie kazdeho vrchola zo vstupnych kombinacii
exctract_tops([], []).
exctract_tops([(X, Y)|T], RestXY) :-
    exctract_tops(T, Rest),
    (   \+ member(X, Rest)
    ->  RestX = [X|Rest]
    ;   RestX = Rest
    ),
    (   \+ member(Y, RestX)
    ->  RestXY = [Y|RestX]
    ;   RestXY = RestX
    ).

%--------------------------Kombinacie--------------------------
%prebrane z https://stackoverflow.com/questions/53668887/a-combination-of-a-list-given-a-length-followed-by-a-permutation-in-prolog

combination(_, 0, []).
combination([X|Xs], N, [X|Ys]) :-
    N > 0,
    N1 is N - 1,
    combination(Xs, N1, Ys).
combination([_|Xs], N, Ys) :-
    N > 0,
    combination(Xs, N, Ys).

generate_combinations(List, N, Combinations) :-
    findall(Comb, combination(List, N, Comb), Combinations).


%-------------------------Cyklenie----------------------------

%vypis vo vysledom formate
print_row([]) :- nl.
print_row([(X,Y)|Rest]) :-
    format('~w-~w ', [X,Y]),
    print_row(Rest).

%predikat vyberie kombinaciu a pokial necykli vypise ju
print_noncycle(_, []).
print_noncycle(Tops, [A|B]) :-
    print_noncycle(Tops, B),
    chose_col(Tops, A, Res),
    (   Res ->  
        true;   
        print_row(A)
    ).

%predikat vyberie vrchol v kombinacii podla ktoreho sa bude zistovat cyklus
chose_col([], _, false).
chose_col([A|RestTop], Arr, TrueFalse):-
    find_cycle([A], Arr, Res),
    (   Res ->  
        TrueFalse = true;   
        chose_col(RestTop, Arr, TrueFalse)
    ).

%predikat vrati true pokial z daneho vrchola vznikne cyklus
find_cycle([A|Visited], Arr, TrueFalse) :-
    find_remove_followers(A, Arr, Followers, RestArr),
    (   member(A, Visited) ->  
        TrueFalse = true;   
        call_find([A|Visited], Followers, RestArr, TrueFalse)
    ).

%predikat vytvori vetvenie rekurzii na zaklade poctu nasledovnikov
call_find(_, [], _, false).
call_find(Visited, [F|Followers], Arr, TrueFalse) :-
    find_cycle([F|Visited], Arr, Res),
    (   Res ->  
        TrueFalse = true;   
        call_find([F|Visited], Followers, Arr, TrueFalse)
    ).

%predikat vrati zoznam dosiahnutelnych vrcholov a zoznam ktory neobhsauje dosiehnutelne vrcholy
find_remove_followers(_, [], [], []).
find_remove_followers(A, [(A,X)|Rest],[X|Followers], RestArr) :-
    find_remove_followers(A, Rest, Followers, RestArr).
find_remove_followers(A, [(X,A)|Rest],[X|Followers], RestArr) :-
    find_remove_followers(A, Rest, Followers, RestArr).
find_remove_followers(A, [X|Rest], Followers, [X|RestArr]) :-
    find_remove_followers(A, Rest, Followers, RestArr).

%Predikat na zistenie ci vrchol je v zozname navstivenych vrcholov
member(X, [X|_]).
member(X, [_|T]) :- 
    member(X, T).