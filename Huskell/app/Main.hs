import System.Random
import Data.Time

-- import библиотеки для параллельного вычисления

-- Radixsort для int
radixsort :: [Int] -> [Int]
radixsort [] = []
radixsort xs =
    let maxPos = floor ((log (fromIntegral (foldl max 0 xs)) / log 10) + 1) -- количество раундов

        -- начать с LSD до максимального разряда
        radixsort' ys pos
         | pos < 0   = ys
         | otherwise = let sortedYs   = radixsort' ys (pos - 1)
                           newBuckets = radixsort'' sortedYs [[] | i <- [1..10]] pos
                       in  [element | bucket <- newBuckets, element <- bucket]

        -- сортировать цифры в бакеты
        radixsort'' []     buckets _   = buckets
        radixsort'' (y:ys) buckets pos =
            let digit = div (mod y (10 ^ (pos + 1))) (10 ^ pos)
                (bucketsBegin, bucketsEnd) = splitAt digit buckets
                bucket = head bucketsEnd
                newBucket = bucket ++ [y]
            in radixsort'' ys (bucketsBegin ++ [newBucket] ++ (tail bucketsEnd)) pos
    in radixsort' xs maxPos

getRandIntArray :: Int -> [Int] 
getRandIntArray seed = (randomRs (0, div (maxBound :: Int) 2) (mkStdGen seed))

main = do
        start <- getCurrentTime
        value <- (\x -> return x ) (length (radixsort (take 2000 (getRandIntArray 0))))
        print value
        stop <- getCurrentTime
        print $ diffUTCTime stop start