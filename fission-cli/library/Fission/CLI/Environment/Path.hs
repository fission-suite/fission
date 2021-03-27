module Fission.CLI.Environment.Path
  ( globalBinaryDir
  , globalIPFSBin
  , globalIPFSRepo
  , globalTmpDir
  , globalKeyDir
  , getSigningKeyPath
  , globalUCANDir
  , globalWNFSDir
  , ucanStorePath
  , wnfsKeyStorePath
  -- * Reexports
  , module Fission.CLI.Environment.Class
  ) where

import qualified Network.IPFS.BinPath.Types    as IPFS
import           RIO.FilePath                  ((</>))

import           Fission.Prelude

import           Fission.CLI.Environment.Class

globalBinaryDir :: MonadEnvironment m => m FilePath
globalBinaryDir = do
  global <- getGlobalPath
  return $ global </> "bin"

globalIPFSBin :: MonadEnvironment m => m IPFS.BinPath
globalIPFSBin = do
  binDir <- globalBinaryDir
  return . IPFS.BinPath $ binDir </> "fission-ipfs"

globalIPFSRepo :: MonadEnvironment m => m FilePath
globalIPFSRepo = do
  global <- getGlobalPath
  return $ global </> "ipfs"

globalTmpDir :: MonadEnvironment m => m FilePath
globalTmpDir = do
  dir <- getGlobalPath
  return $ dir </> "tmp"

globalKeyDir :: MonadEnvironment m => m FilePath
globalKeyDir = do
  dir <- getGlobalPath
  return $ dir </> "key"

getSigningKeyPath ::
  ( MonadIO          m
  , MonadEnvironment m
  )
  => m FilePath
getSigningKeyPath = do
  path <- globalKeyDir
  return $ path </> "machine_id.ed25519"

globalUCANDir :: MonadEnvironment m => m FilePath
globalUCANDir = do
  dir <- getGlobalPath
  return $ dir </> "ucan"

globalWNFSDir :: MonadEnvironment m => m FilePath
globalWNFSDir = do
  dir <- getGlobalPath
  return $ dir </> "wnfs"

wnfsKeyStorePath :: MonadEnvironment m => m FilePath
wnfsKeyStorePath = do
  wnfsDir <- globalWNFSDir
  return (wnfsDir </> "store.json")

ucanStorePath :: MonadEnvironment m => m FilePath
ucanStorePath = do
  ucanDir <- globalUCANDir
  return (ucanDir </> "store.json")
