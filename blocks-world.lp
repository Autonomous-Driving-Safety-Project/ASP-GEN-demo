% This is a demo ASP program for blocks world planning.
% This helps you to understand how the asp planning works.

% The incmode introduce atom t/0 as planning step.
#include <incmode>.

% The code in the base section does not contain 't'.
#program base.
% Definition
block(b0).
block(b1).
block(b2).
location(table).
location(X) :- block(X).
holds(F, 0) :- init(F).


% Initial state:
%
% +---+
% | 2 |
% +---+  +---+
% | 0 |  | 1 |
% +---+  +---+
%%%%%%%%%%%%%%%%%%%%%%

init(on(b1, table)).
init(on(b2, b0)).
init(on(b0, table)).

% Goal state:
%
% +---+
% | 2 |
% +---+
% | 1 |
% +---+
% | 0 |
% +---+
%%%%%%%%%%%%%%%%%%%%%%

goal(on(b1, b0)).
goal(on(b2, b1)).
goal(on(b0, table)).

% The code in the step section will be repeated for each planning step t > 0.
% The recursion logic is defined in this section.
#program step(t).

% This is called the 'aggregate'. It requires that there is one and only one
% move(X, Y, t) should be hold at each t. Moreover, X should be a block, Y
% should be a location, and X is not equal to Y.
{ move(X, Y, t) : block(X), location(Y), X != Y } = 1.

% This defines the effect of move: if move(X, Y, t) is hold, X is on Y at step t.
holds(on(X, Y), t) :- move(X, Y, t).

% A constraint of move: it should be clear on X to move X.
:- move(X, Y, t), holds(on(A, X), t-1).

% Another constraint of move: cannot move to a place where there is a block, except for table.
:- move(X, Y, t), holds(on(B, Y), t-1), B != X, Y != table.

% Definition of atom moved/2
moved(X, t) :- move(X, Y, t).

% The inertia rule: a block stays on the same place if it is not moved.
holds(on(X, Z), t) :- holds(on(X, Z), t-1), not moved(X, t).


% The code in the test section will only be checked at the final step t >= 0.
#program check(t).

% To check if the goal is achieved.
:- query(t), goal(F), not holds(F, t).

% Control which atoms will be printed out.
#show move/3.
