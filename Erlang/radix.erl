-module(radix).
-export([sort/2, getDigitByRank/2, getBuckets/2]).
-import(arrayUtils, [randomArray/3, max/1, splitListAt/2]).
-import(lists, [nth/2]).
-author("Art").

sort(Size, P) ->
  Array = randomArray(Size, 0, 100),
  MaxNum = arrayUtils:max(Array),
  Sorted = sortRec(Array, 1, MaxNum, P),
  {Array, Sorted}.

sortRec(Array, Rank, MaxNum, Depth, P) ->
  if
    (Depth == (P div 2 - 1)) ->
      MiddleIndex = length(Array),
      {LeftArr, RightArr} = arrayUtils:splitListAt(Array, MiddleIndex),
      LeftBuckets = getBuckets(LeftArr, Rank),
      RightBuckets = getBuckets(RightArr, Rank),
      combineBuckets(LeftBuckets, RightBuckets);
    true ->
      MiddleIndex = length(Array),
      {LeftArr, RightArr} = arrayUtils:splitListAt(Array, MiddleIndex),
      LeftBuckets = sortRec(LeftArr, Rank, MaxNum, Depth + 1, P),
      RightBuckets = sortRec(RightArr, Rank, MaxNum, Depth + 1, P),
      combineBuckets(LeftBuckets, RightBuckets)
  end.

sortRec(Array, Rank, MaxNum, P) ->
  if
    (MaxNum div Rank =< 0) ->
      Array;
    true ->
      Combined = sortRec(Array, Rank, MaxNum, 0, P),
      SortedByRank = sortBuckets(Combined),
      sortRec(SortedByRank, Rank * 10, MaxNum, P)
  end.

sortBuckets(Buckets) ->
  sortBuckets(Buckets, [], 1).

sortBuckets(Buckets, Result, Index) ->
  if
    (Index > 10) ->
      Result;
    true ->
      Sorted = Result ++ lists:nth(Index, Buckets),
      sortBuckets(Buckets, Sorted, Index + 1)
  end.

combineBuckets(Left, Right) ->
  combineBuckets(Left, Right, [], 1).

combineBuckets(Left, Right, Result, Index) ->
  if
    (Index > 10) ->
      Result;
    true ->
      Combined = Result ++ [lists:nth(Index, Left) ++ lists:nth(Index, Right)],
      combineBuckets(Left, Right, Combined, Index + 1)
  end.

getBuckets(Array, Rank) ->
  getBuckets(Array, [[], [], [], [], [], [], [], [], [], []], Rank, 1).

getBuckets(Array, ResultArray, Rank, Index) ->
  if
    (Index > length(Array)) ->
      ResultArray;
    true ->
      CurrNumber = lists:nth(Index, Array),
      CurrDigit = getDigitByRank(CurrNumber, Rank),
      {LeftPart, RightPart} = arrayUtils:splitListAt(ResultArray, CurrDigit),
      [Head | Tail] = RightPart,
      NewBuckets = LeftPart ++ ([(Head ++ [CurrNumber])] ++ Tail),
      getBuckets(Array, NewBuckets, Rank, Index + 1)
  end.

getDigitByRank(Number, Rank) ->
  getDigitByRank(Number, Rank, 1).

getDigitByRank(Number, Rank, Counter) ->
  if
    (Number > 0) and (Rank /= Counter) ->
      getDigitByRank((Number div 10), Rank, (Counter * 10));
    true ->
      Number rem 10
  end.