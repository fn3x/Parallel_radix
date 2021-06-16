import System.Random
import Data.Time
import Data.List (delete, maximum)
import Control.Parallel
import Control.Monad

radixSort :: [Int] -> [Int]
radixSort [] = []
radixSort array =
  let
    maxNum = maximum array
    middleIndex = ((length array) `div` 2) - 1

    forLoopSort array rank maxNum
      | (maxNum `div` rank) <= 0 = array
      | otherwise =
        let
          (left, right) = splitAt middleIndex array
          leftBuckets = getBuckets left rank
          rightBuckets = getBuckets right rank
          combined = leftBuckets `par` rightBuckets `par` (leftBuckets `append` rightBuckets)
          reorder = reorderBuckets combined
        in forLoopSort reorder (rank * 10) maxNum

  in forLoopSort array 1 maxNum

append xs ys = [xs] ++ [ys]

reorderBuckets combined =
  let
    arr1 = head combined
    arr2 = last combined
    combineBuckets result i
      | i == 10 = result
      | otherwise =
          let
            newArray = result ++ arr1!!i ++ arr2!!i
          in combineBuckets newArray (i + 1)
  in combineBuckets [] 0

getBuckets :: [Int] -> Int -> [[Int]]
getBuckets array rank =
  let
    forSortLoop buckets i
      | i == length array = buckets
      | otherwise =
          let
            curNumber = array!!i
            currDigit = digitByRank curNumber rank
            (leftPart, rightPart) = splitAt currDigit buckets
            newBuckets = leftPart ++ ([((head rightPart) ++ [curNumber])] ++ tail rightPart)
          in forSortLoop newBuckets (i + 1)
  in forSortLoop [[], [], [], [], [], [], [], [], [], []] 0

digitByRank :: Int -> Int -> Int
digitByRank number rank =
  let
    whileLoop number rank counter
      | number > 0 && rank /= counter =
        whileLoop (number `div` 10) rank (counter * 10)
      | otherwise = number `mod` 10
  in whileLoop number rank 1

randomInts :: Int -> (Int,Int) -> IO [Int]
randomInts len bounds = replicateM len $ randomRIO bounds

main = do
  randomArray <- (randomInts 10000 (0,100))
  start <- getCurrentTime
  result <- (\x -> return x ) (length (radixSort randomArray))
  print result
  stop <- getCurrentTime
  print $ diffUTCTime stop start