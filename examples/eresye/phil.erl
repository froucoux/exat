%
% phil.erl
%
% -------------------------------------------------------------------------
%
%  ERESYE, an ERlang Expert SYstem Engine
%  Copyright (C) 2005-07 Francesca Gangemi (francesca@erlang-consulting.com)
%  Copyright (C) 2005-07 Corrado Santoro (csanto@diit.unict.it)
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>
%
-module (phil).
-compile ([export_all]).

-define (N_PHIL, 5).

start () ->
  eresye:start (restaurant),
  phil_spawn (0).

phil_spawn (?N_PHIL) -> ok;
phil_spawn (N) ->
  eresye:assert (restaurant, {fork, N}),
  spawn (phil, philosopher, [N, init]),
  if
    N < (?N_PHIL - 1) ->
      eresye:assert (restaurant, {room_ticket, N});
    true ->
      ok
  end,
  phil_spawn (N + 1).

philosopher (N, init) ->
  new_seed (),
  philosopher (N, ok);
philosopher (N, X) ->
  think (N),
  Ticket = eresye:wait_and_retract (restaurant, {room_ticket, '_'}),
  eresye:wait_and_retract (restaurant, {fork, N}),
  eresye:wait_and_retract (restaurant, {fork, (N + 1) rem ?N_PHIL}),
  eat (N),
  eresye:assert (restaurant, {fork, N}),
  eresye:assert (restaurant, {fork, (N + 1) rem ?N_PHIL}),
  eresye:assert (restaurant, Ticket),
  philosopher (N, X).

think (N) ->
  io:format ("~w: thinking ...~n", [N]),
  timer:sleep (random:uniform (10) * 1000).

eat (N) ->
  io:format ("~w: eating ...~n", [N]),
  timer:sleep (random:uniform (10) * 1000).


new_seed() ->
  {_,_,X} = erlang:now(),
  {H,M,S} = time(),
  H1 = H * X rem 32767,
  M1 = M * X rem 32767,
  S1 = S * X rem 32767,
  put(random_seed, {H1,M1,S1}).
