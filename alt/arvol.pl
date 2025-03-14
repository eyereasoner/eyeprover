% -------------------
% arvol -- Jos De Roo
% -------------------
%
% See https://github.com/eyereasoner/arvol
%

:- use_module(library(lists)).
:- use_module(library(terms)).

:- op(1200, xfx, :+).

:- dynamic((:+)/2).
:- dynamic(answer/1).
:- dynamic(brake/0).
:- dynamic(closure/1).
:- dynamic(count/2).
:- dynamic(fuse/1).
:- dynamic(limit/1).
:- dynamic(step/3).

version('arvol v0.0.16 (2025-03-13)').

% main goal
go :-
    catch(use_module(library(iso_ext)), _, true),
    catch(use_module(library(format)), _, true),
    catch(use_module(library(between)), _, true),
    assertz(closure(0)),
    assertz(limit(-1)),
    assertz(count(f, 0)),
    assertz(count(m, 0)),
    (   (_ :+ _)
    ->  true
    ;   version(Version),
        format(user_error, "~w~n", [Version]),
        halt(0)
    ),
    forall(
        (Conc :+ Prem),
        dyn((Conc :+ Prem))
    ),
    catch(eam, E,
        (   (   E = halt(Exit)
            ->  true
            ;   format(user_error, "*** ~w~n", [E]),
                Exit = 1
            )
        )
    ),
    count(f, F),
    (   F = 0
    ->  true
    ;   format(user_error, "*** f=~w~n", [F])
    ),
    count(m, M),
    (   M = 0
    ->  true
    ;   format(user_error, "*** m=~w~n", [M])
    ),
    (   Exit = 0
    ->  true
    ;   true
    ),
    halt(Exit).

% -----------------
% eye arvol machine
% -----------------
%
% 1/ select rule Conc :+ Prem
% 2/ prove Prem and if it fails backtrack to 1/
% 3/ if Conc = true assert answer + step
%    else if Conc = false output fuse + steps and stop
%    else if ~Conc assert Conc + step and retract brake
% 4/ backtrack to 2/ and if it fails go to 5/
% 5/ if brake
%       if not stable start again at 1/
%       else output answers + steps and stop
%    else assert brake and start again at 1/
%

eam :-
    (   (Conc :+ Prem),                         % 1/
        copy_term((Conc :+ Prem), Rule),
        Prem,                                   % 2/
        (   Conc = true                         % 3/
        ->  aconj(answer(Prem)),
            aconj(step(Rule, Prem, Conc))
        ;   (   Conc = false
            ->  format(":- op(1200, xfx, :+).~n~n", []),
                portray_clause(fuse(Prem)),
                (   step(_, _, _),
                    nl
                ->  forall(
                        step(R, P, C),
                        portray_clause(step(R, P, C))
                    )
                ;   true
                ),
                throw(halt(2))
            ;   (   Conc \= (_ :+ _)
                ->  skolemize(Conc, 0, _)
                ;   true
                ),
                \+ Conc,
                aconj(Conc),
                aconj(step(Rule, Prem, Conc)),
                retract(brake)
            )
        ),
        fail                                    % 4/
    ;   (   brake                               % 5/
        ->  (   closure(Closure),
                limit(Limit),
                Closure < Limit,
                NewClosure is Closure+1,
                becomes(closure(Closure), closure(NewClosure)),
                eam
            ;   format(":- op(1200, xfx, :+).~n~n", []),
                forall(
                    answer(P),
                    portray_clause(answer(P))
                ),
                (   step(_, _, _),
                    nl
                ->  forall(
                        step(R, P, C),
                        portray_clause(step(R, P, C))
                    )
                ;   true
                )
            )
        ;   assertz(brake),
            eam
        )
    ).

% assert conjunction
aconj((B, C)) :-
    aconj(B),
    aconj(C).
aconj(A) :-
    (   \+ A
    ->  assertz(A)
    ;   true
    ).

% skolemize
skolemize(Term, N0, N) :-
    term_variables(Term, Vars),
    skolemize_(Vars, N0, N).

skolemize_([], N, N) :-
    !.
skolemize_([Sk|Vars], N0, N) :-
    number_chars(N0, C0),
    atom_chars(A0, C0),
    atom_concat('sk_', A0, Sk),
    N1 is N0+1,
    skolemize_(Vars, N1, N).

% stable(+Level)
%   fail if the deductive closure at Level is not yet stable
stable(Level) :-
    limit(Limit),
    (   Limit < Level
    ->  becomes(limit(Limit), limit(Level))
    ;   true
    ),
    closure(Closure),
    Level =< Closure.

% linear implication
becomes(A, B) :-
    catch(A, _, fail),
    clist(A, C),
    forall(
        member(D, C),
        retract(D)
    ),
    clist(B, E),
    forall(
        member(F, E),
        assertz(F)
    ).

% conjunction tofro list
clist(true, []).
clist(A, [A]) :-
    A \= (_, _),
    A \= false,
    !.
clist((A, B), [A|C]) :-
    clist(B, C).

% make dynamic predicates
dyn(A) :-
    var(A),
    !.
dyn(A) :-
    atomic(A),
    !.
dyn([]) :-
    !.
dyn([A|B]) :-
    !,
    dyn(A),
    dyn(B).
dyn(A) :-
    A =.. [B|C],
    length(C, N),
    (   current_predicate(B/N)
    ->  true
    ;   functor(T, B, N),
        catch((assertz(T), retract(T)), _, true)
    ),
    dyn(C).

% debugging tools
f(A) :-
    format(user_error, "*** ~q~n", [A]),
    count(f, B),
    C is B+1,
    becomes(count(f, B), count(f, C)).

m(A) :-
    forall(
        catch(A, _, fail),
        (   format(user_error, "*** ", []),
            portray_clause(user_error, A),
            count(m, B),
            C is B+1,
            becomes(count(m, B), count(m, C))
        )
    ).
