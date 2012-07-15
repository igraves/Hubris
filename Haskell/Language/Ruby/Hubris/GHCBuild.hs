module Language.Ruby.Hubris.GHCBuild (ghcBuild, defaultGHCOptions, GHCOptions(..), withTempFile) where
import Config
import Debug.Trace
import DynFlags
import GHC
import GHC.Paths
import Outputable
import StringBuffer
import System.Process
import Control.Monad(forM_,guard)
import System.IO(hPutStr, hClose, openTempFile)
import System.Exit
import Language.Ruby.Hubris.Includes (extraIncludeDirs) -- this is generated by Cabal


newtype GHCOptions = GHCOptions { strict :: Bool }
defaultGHCOptions = GHCOptions { strict = True }
type Filename = String


standardGHCFlags = (words $ "--make -shared -dynamic -fPIC -optc-DHAVE_SNPRINTF -lHSrts-ghc" ++Config.cProjectVersion)
                   ++ map ("-I"++) extraIncludeDirs
                           
withTempFile :: String -> String -> IO String
withTempFile pattern code = do (name, handle) <- openTempFile "/tmp" pattern
                               hPutStr handle code
                               hClose handle
                               return name

ghcBuild :: Filename -> String -> String -> [Filename] -> [Filename] -> [String]-> IO (Either String Filename)
ghcBuild libFile immediateSource modName extra_sources c_sources args =
    do -- putStrLn ("modname is " ++ modName)
          putStrLn immediateSource
          haskellSrcFile <- withTempFile "hubris_XXXXX.hs" immediateSource
          putStrLn ("ghc is " ++ ghc)
          (code, out, err) <- noisySystem ghc $ standardGHCFlags ++ ["-o",libFile,"-optl-Wl,-rpath," ++ libdir,
                                                                     haskellSrcFile, "-L" ++ libdir] ++ extra_sources ++ c_sources ++ args
          return $ case code of
            ExitSuccess -> Right libFile
            otherCode   -> Left $ unlines ["Errcode: " ++show code,"output: " ++ out, "error: " ++ err]
               
noisySystem :: String -> [String] -> IO (ExitCode, String,String)
noisySystem cmd args = (putStrLn . unwords) (cmd:args) >> readProcessWithExitCode cmd args ""

 
