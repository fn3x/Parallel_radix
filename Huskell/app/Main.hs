import System.Random
import Data.Time
import Data.List (delete, maximum)
import Control.Parallel
import Control.Monad
import Debug.Trace
import System.Environment
import System.IO

radixSort :: [Int] -> Int -> [Int]
radixSort [] _ = []
radixSort array p =
  let
    maxNum = maximum array
    forLoopSort array rank maxNum
      | (maxNum `div` rank) <= 0 = array
      | otherwise = forLoopSort (sortBuckets (parallelSplit array 0)) (rank * 10) maxNum            
        where
          parallelSplit array depth
            | depth == ((p `div` 2) - 1) =
              let
                middleIndex = ((length array) `div` 2) - 1
                (leftArray, rightArray) = splitAt middleIndex array
                leftBuckets = getBuckets leftArray rank
                rightBuckets = getBuckets rightArray rank
              in leftBuckets `par` rightBuckets `par` (combineBuckets leftBuckets rightBuckets)

            | otherwise = leftBuckets `par` rightBuckets `par` (combineBuckets leftBuckets rightBuckets)
              where
                leftBuckets = parallelSplit leftArray (depth + 1)
                rightBuckets = parallelSplit rightArray (depth + 1)
                middleIndex = ((length array) `div` 2) - 1
                (leftArray, rightArray) = splitAt middleIndex array

  in forLoopSort array 1 maxNum

sortBuckets :: [[Int]] -> [Int]
sortBuckets buckets =
  let
    getNumbers result i
      | i == 10 = result
      | otherwise =
          let
            newArray = result ++ buckets!!i
          in getNumbers newArray (i + 1)
  in getNumbers [] 0

combineBuckets :: [[Int]] -> [[Int]] -> [[Int]]
combineBuckets leftBuckets rightBuckets =
  let
    combineBuckets result i
      | i == 10 = result
      | otherwise =
          let
            combined = result ++ [leftBuckets!!i ++ rightBuckets!!i]
          in combineBuckets combined (i + 1)
  in combineBuckets [] 0

debug = flip trace

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

readInt:: String -> Int
readInt = read

main = do
  contents <- readFile "5000.txt"
  
  let array = map readInt . words $ contents
  start <- getCurrentTime
  result <- (\x -> return x ) (length (radixSort array 8))
  print result
  stop <- getCurrentTime
  print $ diffUTCTime stop start