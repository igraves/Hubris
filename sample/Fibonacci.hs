module Fibonacci where
-- module Test where

import Foreign.C.Types
-- import Data.Map
import Maybe

-- main = putStrLn "11"

fibonacci :: Integer -> Integer
fibonacci n = fibs !! (fromIntegral n)
  where fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

-- local_map = Data.Map.fromList [(1,2), (3,4)]



-- lookup_hs ::CInt -> CInt
-- lookup_hs = fromIntegral . Maybe.fromJust . ((flip Data.Map.lookup) local_map) . fromIntegral
