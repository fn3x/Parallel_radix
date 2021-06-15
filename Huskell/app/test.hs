import System.Random
import Data.Time
import Data.List (delete)

-- import библиотеки для параллельного вычисления

-- for rank = 1; maxNum / rank > 0; rank *= 10
--    sort(left, rank) 'par' sort(right, rank)
--    reorder(left, right)
--      [20, 12, 30]

-- radixSort :: [Int] -> [Int]
-- radixSort [] = []
-- raidxSort array =
--   let maxPos = floor ((log (fromIntegral (foldl max 0 array)) / log 10) + 1)

--   in 

localSort :: [Int] -> Int -> [Int]
localSort [] _ = []
localSort xs rank =
  let x = minimumByRank xs rank
  in  x : ssort (delete x xs) rank

minimumByRank array rank =
  let
    getDigit array index rank =
      digitByRank (array!!index) rank
    
    findMin array rank currIndex minIndex
      | (getDigit array currIndex rank) < (getDigit array minIndex rank) = currIndex
      | otherwise = minIndex

    forLoop i array rank indexOfMin
      | i < (length array) =
          forLoop (i + 1) array rank (findMin array rank i indexOfMin)
      | otherwise = array!!indexOfMin
  
  in forLoop 0 array rank 0

digitByRank :: Int -> Int -> Int
digitByRank number rank =
  let
    whileLoop number rank counter
      | number > 0 && rank /= counter =
        whileLoop (number `div` 10) rank (counter * 10)
      | otherwise = number `mod` 10
  in whileLoop number rank 1

getRandIntArray :: Int -> [Int] 
getRandIntArray seed = (randomRs (0, div (maxBound :: Int) 2) (mkStdGen seed))

main = do
        -- start <- getCurrentTime
        -- value <- (\x -> return x ) (length (radixsort (take 2000 (getRandIntArray 0))))
        -- print value
        value <- (\x -> return x ) (localSort [533, 524, 451] 100)
        print value
        -- stop <- getCurrentTime
        -- print $ diffUTCTime stop start