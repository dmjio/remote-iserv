module Main where

import Control.Concurrent
import Control.Monad
import Foreign.C.String
import Remote.Slave

foreign import ccall unsafe "getPath" getPath :: IO CString

main :: IO ()
main = do
  startSlave True 5001 =<< getPath
  forever $ threadDelay (secs 1)
    where
      secs = (*1000000)

