-module(radixsort).
-export([sort/2, getDigitByRank/2, getBuckets/2]).
-import(arrayUtils, [randomArray/3, max/1, splitListAt/2]).
-author("Art").

sort(Size, P) ->
  Array = randomArray(Size, 0, 100),
  Max = max(Array).

getBuckets(Array, Rank) ->
  getBuckets(Array, [[], [], [], [], [], [], [], [], [], []], Rank, 0).

getBuckets(Array, ResultArray, Rank, Index) ->
  ResultArray.

getDigitByRank(Number, Rank) ->
  getDigitByRank(Number, Rank, 1).

getDigitByRank(Number, Rank, Counter) ->
  if
    (Number > 0) and (Rank /= Counter) ->
      getDigitByRank((Number div 10), Rank, (Counter * 10));
    true ->
      Number rem 10
  end.