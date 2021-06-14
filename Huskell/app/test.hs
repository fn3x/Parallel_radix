import System.Random
import Data.Time

-- import библиотеки для параллельного вычисления

-- Radixsort для int
-- sort :: [Int] -> Int -> [Int]
-- sort [] _ = []
digitByRank :: Int -> Int -> Int

digitByRank number rank =
  let
    whileLoop number rank counter
      | number > 0 && rank /= counter =
        whileLoop (number `div` 10) rank (counter * 10)
      | otherwise = number `mod` 10
  in whileLoop number rank 1
  
-- sort array rank =
--   ssort xs rank =
--     let x = minimum xs rank
--     in  x : ssort (delete x xs) rank

-- minimum = 9
-- for (i = 0; i < arrayLen; i++)
--  currentNumber = getDigit(array[i], rank)
--    if (currentNumber < min)
--      min = currentNumber
-- return min
minimum array rank =
  let
    forLoop i array rank min
      | i < length array =
          currentNumber = getDigit
  
  in forLoop 0 array rank 9



-- for rank = 1; maxNum / rank > 0; rank *= 10
--    sort(left, rank) 'par' sort(right, rank)
--    reorder(left, right)
--      [20, 12, 30]
getRandIntArray :: Int -> [Int] 
getRandIntArray seed = (randomRs (0, div (maxBound :: Int) 2) (mkStdGen seed))

main = do
        -- start <- getCurrentTime
        -- value <- (\x -> return x ) (length (radixsort (take 2000 (getRandIntArray 0))))
        -- print value
        value <- (\x -> return x ) (digitByRank 1234 1000)
        print value
        -- stop <- getCurrentTime
        -- print $ diffUTCTime stop start