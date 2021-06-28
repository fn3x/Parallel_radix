-module(radixsort).
-export([sort/1, findMax/1]).
-import(array, [randomList/3, max/1]).
-author("Art").

sort(Array) ->
  max(Array).

findMax(Array) ->
  max(Array).