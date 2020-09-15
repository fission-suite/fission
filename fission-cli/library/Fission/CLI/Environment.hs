-- | Reading and writing local user config values
module Fission.CLI.Environment
  ( init
  , get
  , couldNotRead
  , getOrRetrievePeers

  -- * Reexport

  , module Fission.CLI.Environment.Class
  , module Fission.CLI.Environment.Types
  , module Fission.CLI.Environment.Path
  ) where

import           Data.List.NonEmpty            as NonEmpty
import qualified Data.Yaml                     as YAML

import           Servant.Client

import qualified Network.IPFS.Types            as IPFS
import qualified System.Console.ANSI           as ANSI

import           Fission.Prelude

import           Fission.Error.NotFound.Types

import           Fission.Web.Client
import           Fission.Web.Client.Peers      as Peers

import qualified Fission.CLI.Display.Error     as CLI.Error
import qualified Fission.CLI.YAML              as YAML

import           Fission.CLI.Environment.Class
import           Fission.CLI.Environment.Path
import           Fission.CLI.Environment.Types

import qualified Fission.Internal.UTF8         as UTF8

-- | Initialize the Environment file
init ::
  ( MonadIO          m
  , MonadEnvironment m
  , MonadLogger      m
  , MonadWebClient   m

  , MonadCleanup m
  , m `Raises` ClientError
  , Show (OpenUnion (Errors m))
  )
  => m ()
init = do
  logDebug @Text "Initializing config file"

  attempt Peers.getPeers >>= \case
    Left err ->
      CLI.Error.put err "Peer retrieval failed"

    Right nonEmptyPeers -> do
      let
        env = Env
          { peers          = NonEmpty.toList nonEmptyPeers
          , ignored        = ignoreDefault
          , serverDID      = undefined -- FIXME
          , signingKeyPath = undefined -- FIXME
          }

      path <- absPath
      path `YAML.writeFile` env

-- | Gets hierarchical environment by recursing through file system
get ::
  ( MonadIO          m
  , MonadEnvironment m
  , MonadRaise       m
  , m `Raises` YAML.ParseException
  , m `Raises` NotFound FilePath
  )
  => m Env
get = YAML.readFile =<< absPath

-- | Retrieves a Fission Peer from local config
--   If not found we retrive from the network and store
getOrRetrievePeers ::
  ( MonadIO          m
  , MonadLogger      m
  , MonadWebClient   m
  , MonadEnvironment m

  , MonadCleanup m
  , m `Raises` ClientError
  , m `Raises` YAML.ParseException
  , m `Raises` NotFound FilePath
  , Show (OpenUnion (Errors m))
  )
  => Env
  -> m [IPFS.Peer]
getOrRetrievePeers Env {peers = []} =
  attempt Peers.getPeers >>= \case
    Left err -> do
      logError $ displayShow err
      logDebug @Text "Unable to retrieve peers from the network"
      return []

    Right nonEmptyPeers -> do
      logDebug $ "Retrieved Peers from API, and writing to ~/.fission.yaml: " <> textShow peers

      path    <- absPath
      current <- YAML.readFile path

      let
        peers = peers current <> NonEmpty.toList nonEmptyPeers

      writeFile path current { peers }
      return peers

getOrRetrievePeers Env {peers} = do
  logDebug $ "Retrieved Peers from .fission.yaml: " <> textShow peers
  return peers

absPath :: MonadEnvironment m => m FilePath
absPath = do
  path <- getGlobalPath
  return $ path </> "config.yaml"
