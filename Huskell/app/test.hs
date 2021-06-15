import System.Random
import Data.Time
import Data.List (delete)
import Control.Parallel
import Control.Monad

-- import библиотеки для параллельного вычисления

-- for rank = 1; maxNum / rank > 0; rank *= 10
--    sort(left, rank) 'par' sort(right, rank)
--    reorder(left, right)
--      [20, 12, 30]

radixSort :: [Int] -> [Int]
radixSort [] = []
radixSort array =
  let
    maxNum = maximum'' array
    lastIndex = (length array) - 1
    middleIndex = ((length array) `div` 2) - 1

    forLoopSort array rank maxNum
      | (maxNum `div` rank) <= 0 = array
      | otherwise =
        let
          left = slice 0 middleIndex array
          right = slice (middleIndex + 1) lastIndex array
          sortLeft = localSort left rank
          sortRight = localSort right rank

          reorder = localSort (sortLeft `par` sortRight `par` sortLeft ++ sortRight) rank

        in forLoopSort reorder (rank * 10) maxNum

  in forLoopSort array 1 maxNum

maximum' :: Ord a => [a] -> a
maximum' = foldr1 (\x y ->if x >= y then x else y)

maximum'' :: Ord a => [a] -> a
maximum'' [x]       = x
maximum'' (x:x':xs) = maximum' ((if x >= x' then x else x'):xs)

slice :: Int -> Int -> [a] -> [a]
slice from to xs = take (to - from + 1) (drop from xs)

localSort :: [Int] -> Int -> [Int]
localSort [] _ = []
localSort xs rank =
  let x = minimumByRank xs rank
  in  x : localSort (delete x xs) rank

minimumByRank array rank =
  let
    getDigitAt index = digitByRank (array!!index) rank
    
    findMin array rank currIndex minIndex
      | (getDigitAt currIndex) < (getDigitAt minIndex) = currIndex
      | otherwise = minIndex

    forMinLoop i array rank indexOfMin
      | i < (length array) =
          forMinLoop (i + 1) array rank (findMin array rank i indexOfMin)
      | otherwise = array!!indexOfMin
  
  in forMinLoop 0 array rank 0

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
  randomArray <- (randomInts 1000000 (1,1000))
  start <- getCurrentTime
  value <- (\x -> return x ) (length (radixSort randomArray))
  stop <- getCurrentTime
  print $ diffUTCTime stop start