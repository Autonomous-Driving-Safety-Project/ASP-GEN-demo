% This is a demo ASP program for road scenario.
% There are only 2 cars in this scenario: ego and car.
% To make it more simple, only longitudinal movement is considered.
% And the length of the cars are not considered.

#include <incmode>.

#program base.

% Limits of the position and speed.
#const posmax = 100.
#const posmin = -100.
#const spdmax = 20.
#const spdmin = -20.

% Definition of the cars, position and speed.
is_car(ego;car).
is_position(posmin..posmax).
is_speed(spdmin..spdmax).

% init state
position(ego,-50).
speed(ego, 0).

position(car, 0).
speed(car, 0).

% Definition of the maneuvers.
longitudinal_maneuver(accelerate_hard).
longitudinal_maneuver(decelerate_hard).
longitudinal_maneuver(keep_speed).

% speed, position and maneuver at time 0.
occurs(keep_speed, Car, 0) :- is_car(Car).
h(position(A, B), 0) :- position(A, B), is_car(A).
h(speed(A, B), 0) :- speed(A, B), is_car(A).

#program step(t).

% Each car should have one and only one position, speed and maenuver.
{ h(position(Car, Pos), t) : is_position(Pos) } = 1 :- is_car(Car).
{ h(speed(Car, Spd), t) : is_speed(Spd) } = 1 :- is_car(Car).
{ occurs(Maneuver, Car, t): longitudinal_maneuver(Maneuver); h(during_longitudinal_maneuver(Car), t) } = 1 :- is_car(Car).

% Position update rules
h(position(Car, Pos + Spd), t) :-
    is_car(Car),
    is_position(Pos),
    is_position(Pos + Spd),
    is_speed(Spd),
    h(speed(Car, Spd), t - 1),
    h(position(Car, Pos), t - 1).
:- not is_position(Pos + Spd), is_car(Car), h(position(Car, Pos), t), h(speed(Car, Spd), t).

%%%%%%%%%%%%% Longitudinal Maneuvers %%%%%%%%%%%%%

%%%%%% maneuver accelerate_hard
%%%%%%   last for 1 seconds
%%%%%%   increase speed by 3 m/s

% This describe the effect of maneuver accelerate_hard: the speed+3 after 1 second
h(speed(Car, Spd + 3), t) :-
    occurs(accelerate_hard, Car, t-1),
    is_car(Car),
    is_speed(Spd),
    h(speed(Car, Spd), t-1).
% After 1 second, the maneuver accelerate_hard is finished. Cause during_longitudinal_maneuver is manually negated,
% another new maneuver should be assigned to the car.
-h(during_longitudinal_maneuver(Car), t) :-
    occurs(accelerate_hard, Car, t-1),
    is_car(Car).
% The speed cannot exceed the limit.
:- occurs(accelerate_hard, Car, t), h(speed(Car, Spd), t), is_car(Car), Spd >= spdmax - 3.

%%%%%% maneuver decelerate_hard
%%%%%%   last for 1 seconds
%%%%%%   decrease speed by 3 m/s
h(speed(Car, Spd - 3), t) :-
    occurs(decelerate_hard, Car, t-1),
    is_car(Car),
    is_speed(Spd),
    h(speed(Car, Spd), t-1).
-h(during_longitudinal_maneuver(Car), t) :-
    occurs(decelerate_hard, Car, t-1),
    is_car(Car).
:- occurs(decelerate_hard, Car, t), h(speed(Car, Spd), t), is_car(Car), Spd <= spdmin + 3.

%%%%%% maneuver keep_speed
%%%%%%   last for 1 seconds
%%%%%%   keep current speed
h(speed(Car, Spd), t) :-
    occurs(keep_speed, Car, t-1),
    is_car(Car),
    is_speed(Spd),
    h(speed(Car, Spd), t-1).
-h(during_longitudinal_maneuver(Car), t) :-
    occurs(keep_speed, Car, t-1),
    is_car(Car).

% When it's during longitudinal maneuver, cannot occur another one.
:- occurs(Maneuver, Car, t), h(during_longitudinal_maneuver(Car), t), is_car(Car), longitudinal_maneuver(Maneuver).

#program check(t).

% Definition of exist_over and exist_behind.

% Exist a car B whose position is >= A's.
h(exist_over(A), t) :-
    is_car(A),
    is_car(B),
    A != B,
    h(position(A, PosA), t),
    h(position(B, PosB), t),
    is_position(PosA),
    is_position(PosB),
    PosA <= PosB.
% Exist a car B whose position is <= A's.
h(exist_behind(A), t) :-
    is_car(A),
    is_car(B),
    A != B,
    h(position(A, PosA), t),
    h(position(B, PosB), t),
    is_position(PosA),
    is_position(PosB),
    PosA>= PosB.

% The goal is no one is over ego.
goal(done, t) :-
   not h(exist_over(ego), t).

% At the last timestep, maneuver should be keep_speed, cause the last maneuvers' effect will not be performed.
:- goal(done, t), not occurs(keep_speed, Car, t), is_car(Car).

% To check if the goal is achieved.
{ task(done) } = 1.
:- query(t), not goal(Task, t), task(Task).

% only display maneuvers.
#show occurs/3.
