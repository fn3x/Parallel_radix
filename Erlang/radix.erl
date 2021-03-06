-module(radix).
-export([sort/2, benchmark/3, fileSort/2]).
-import(arrayUtils, [max/1, splitListAt/2]).
-import(lists, [nth/2]).
-author("Art").

benchmark(Fun, L, P) ->
  Runs = [timer:tc(?MODULE, Fun, [L, P])
          || _ <- lists:seq(1, 10)],
  lists:sum([T || {T, _} <- Runs]) / (1000 * length(Runs)).

fileSort(P, Filename) ->
  case file:open(Filename, [read]) of
    {ok, IoDevice} ->
      List = readFile2(IoDevice, []),
      file:close(IoDevice),
      StartTime = erlang:system_time(millisecond),
      sort(List, P),
      EndTime = erlang:system_time(millisecond),
      io:format("Sort time: ~p~n", [(EndTime - StartTime)/1000]),
      file:close(IoDevice);
    {error, Reason} ->  io:format("~p", [Reason])
  end.

readFile2( IoDevice, List ) ->
  case file:read_line(IoDevice) of
    {ok, Data} ->
      Res = lists:map(
        fun(String) ->
          list_to_integer(String) end,
        string:tokens(Data, " ")),
      readFile2(IoDevice, lists:append(List, Res));
    eof -> List
  end.

sort(Array, P) ->
  MaxNum = arrayUtils:max(Array),
  StartTime = erlang:system_time(millisecond),
  sortRec(Array, 1, MaxNum, P),
  EndTime = erlang:system_time(millisecond),
  io:format("Sort time: ~p~n", [(EndTime - StartTime)/1000]).

sortRec(Array, Rank, MaxNum, P) ->
  if
    (MaxNum div Rank =< 0) ->
      Array;
    true ->
      Combined = sortRec(Array, Rank, MaxNum, P div 2, P),
      SortedByRank = sortBuckets(Combined),
      sortRec(SortedByRank, Rank * 10, MaxNum, P)
  end.

sortRec(Array, Rank, MaxNum, Depth, P) ->
  if
    (Depth == 0) ->
      getBuckets(Array, Rank);
    true ->
      MiddleIndex = length(Array),
      {LeftArr, RightArr} = arrayUtils:splitListAt(Array, MiddleIndex),
      Parent = self(),
      RefLeft = make_ref(),
      RefRight = make_ref(),
      spawn_link(fun() ->
        Parent ! {RefLeft, sortRec(LeftArr, Rank, MaxNum, Depth - 1, P)}
      end),
      spawn_link(fun() ->
        Parent ! {RefRight, sortRec(RightArr, Rank, MaxNum, Depth - 1, P)}
      end),
      combineBuckets(receive {RefLeft, LeftBuckets} -> LeftBuckets end, receive {RefRight, RightBuckets} -> RightBuckets end)
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