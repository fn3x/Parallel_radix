-module(arrayUtils).
-export([randomArray/3, max/1, splitListAt/2]).
-author("Art").

randomArray(Size, Min, Max) ->
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

splitListAt(Array, At) ->
  splitListAt(Array, At, 0, [], []).

splitListAt([], _, _, L, R) ->
  {reverse(L), reverse(R)};

splitListAt([H|T], At, Index, L, R) ->
  if
    (Index < At) ->
      splitListAt(T, At, Index + 1, [H|L], R);
    true ->
      splitListAt(T, At, Index + 1, L, [H|R])
  end.

reverse(L) -> reverse(L,[]). 
reverse([],R) -> R;
reverse([H|T],R) -> reverse(T,[H|R]).