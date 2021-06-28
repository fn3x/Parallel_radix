-module(array).
-export([randomList/3, max/1]).
-author("Art").

randomList(Size, Min, Max) ->
  [rand:uniform(Max) || _ <- lists:seq(Min, Size)].

max(Array) ->
  maximum(Array).

maximum([]) ->
  io:format("can not find max from empty list~n");
maximum([H|T]) ->
  maximum(H, T).

maximum(Max, [H|T]) ->
  case Max > H of
  true    -> maximum(Max, T);
  false   -> maximum(H, T)
  end;
maximum(Max, []) ->
  Max.