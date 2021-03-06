module Storage where

import Types

import qualified System.Directory as SD
import qualified System.IO as SI
import qualified Data.HashSet as HS
import Data.HashSet (HashSet)
import qualified Data.Text as T
import Data.Text (Text)
import qualified Data.Text.IO as TIO

readUrlsFromFile :: String -> IO [Url]
readUrlsFromFile filePath =
  T.lines <$> TIO.readFile filePath

createFileIfNotExist :: String -> IO ()
createFileIfNotExist filePath =
  SD.doesFileExist filePath >>= \exists ->
    if exists then
      pure ()
    else
      SI.writeFile filePath ""

fileNameForURL :: Url -> String
fileNameForURL url =
  let noTrailingSlash = T.dropWhileEnd (== '/')
      afterProtocol = last . T.splitOn "://"
      cleaned = T.replace "/" "-"
      composed = T.unpack $ (cleaned . afterProtocol . noTrailingSlash) url
   in composed ++ ".txt"

-- https://www.stackage.org/haddock/lts-11.17/unordered-containers-0.2.9.0/Data-HashSet.html
-- A bloom filter should actually be enough to reduce memory footprint
loadPersistedResultsForURL :: String -> IO (HashSet Text)
loadPersistedResultsForURL filePath = buildSet <$> TIO.readFile filePath
  where buildSet fileContent = foldr HS.insert HS.empty $ entries fileContent
        entries fileContent = map (last . T.splitOn " --> ") (T.lines fileContent)

validatePersistingFolder :: Maybe String -> IO ()
validatePersistingFolder Nothing = pure ()
validatePersistingFolder (Just df) =
  SD.doesDirectoryExist df >>= \exists ->
   if not exists
    then
      fail("directory " ++ df ++ " does not exist")
    else
       pure ()