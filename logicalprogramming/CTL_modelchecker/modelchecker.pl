% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).

% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(T), read(L), read(S), read(F), seen,
    check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid. 
%
% (T,L), S |- F 
%           U

% To execute: consult('your_file.pl'). verify('input.txt').

% Atoms
atomcheck([X|_],X):- !.
atomcheck([_|T],X):-
    atomcheck(T,X).

atomcheck([[S|[T]]|_],S,X):-
    !,atomcheck(T,X).

atomcheck([[_|[_]]|F],S,X):-
	atomcheck(F,S,X).

% Literals
check(_, L, S, [], X) :- 
    atomcheck(L,S,X),!.
	
check(_, L, S, [], neg(X)) :- 
	\+ atomcheck(L,S,X),!.


% And
check(T, L, S, [], and(X,Y)) :- 
	check(T,L,S,[],X),check(T,L,S,[],Y).

% Or 
check(T, L, S, [], or(X,Y)):-
	check(T,L,S,[],X),!;check(T,L,S,[],Y).


% AX i nästa tillstånd φ
check(T,L,S,[],ax(X)):-
    axStates(T,L,S,[],T,X),!.

% EX i något nästa tillstånd φ
check(T,L,S,[],ex(X)):-
    exStates(T,L,S,[],T,X),!.

% AG alltid φ -> φ ^ AX(AG(φ))
check(T,L,S,U,ag(X)):- 
    !,
    % AG1
    ((memberchk(S,U),!);
    % AG2
	(
        check(T,L,S,[],X),
	    axStates(T,L,S,[S|U],T,ag(X))
    )).

% EG det finns en väg där alltid φ
check(T,L,S,U,eg(X)):- 
    !,
    % EG1
    ((memberchk(S,U),!);
    % EG2
	(
        check(T,L,S,[],X),
	    exStates(T,L,S,[S|U],T,eg(X))
    )).

% EF det finns en väg där så småningom φ
check(T,L,S,U,ef(X)):-
	!,
    % EF1 
    \+ memberchk(S,U),
    % EF2
	(
        (check(T,L,S,[],X),!);
	    exStates(T,L,S,[S|U],T,ef(X))
    ).

% AF så småningom φ -> φ | AXAF(φ)
check(T,L,S,U,af(X)):- 
	!, 
    % AF1
    \+ memberchk(S,U),
    % AF2
	(
        (check(T,L,S,[],X),!);
	    axStates(T,L,S,[S|U],T,af(X))
    ).

%select members check	
select(X,[X|T],T).
select(X,[Y|T],[Y|R]) :- select(X,T,R).

member(X,L) :- select(X,L,_).
memberchk(X,L) :- select(X,L,_), !.


%axStates - all next states must pass check
axStates(_,_,_,_,[],_):- !, false.

axStates(T,L,S,U,[[S,States]|_],X):-
    !,axStatesCheck(T,L,States,U,X).

axStates(T,L,S,U,[_|Tail],X):-
    !,axStates(T,L,S,U,Tail,X).

axStatesCheck(T,L,[S],U,X):-
    !,check(T,L,S,U,X).

axStatesCheck(T,L,[S|Tail],U,X):-
    axStatesCheck(T,L,Tail,U,X),
    check(T,L,S,U,X).

%exState - one next state must pass
exStates(_,_,_,_,[],_):- !, false.

exStates(T,L,S,U,[[S,States]|_],X):-
    !,exStatesCheck(T,L,States,U,X).

exStates(T,L,S,U,[_|Tail],X):-
    !,exStates(T,L,S,U,Tail,X).

exStatesCheck(T,L,[S],U,X):-
    check(T,L,S,U,X).

exStatesCheck(T,L,[S|Tail],U,X):-
    exStatesCheck(T,L,Tail,U,X);
    check(T,L,S,U,X).
