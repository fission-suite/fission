module Main (main) where

import           RIO
import           RIO.Process (mkDefaultProcessContext)

import           Data.Aeson (decodeFileStrict)
import           Servant.Client
import           System.Envy

import qualified Network.HTTP.Client as HTTP
import           Network.Wai.Handler.Warp
import           Network.Wai.Handler.WarpTLS
import           Network.Wai.Middleware.RequestLogger

import           Fission.Config.Types
import           Fission.Storage.PostgreSQL as PostgreSQL
import           Database.Selda.PostgreSQL

import           Fission.Environment
import           Fission.Internal.Orphanage.RIO ()

import           Fission.Storage.Types as DB
import qualified Fission.IPFS.Types    as IPFS
import qualified Fission.Monitor       as Monitor

import qualified Fission.Web           as Web
import qualified Fission.Web.CORS      as CORS
import qualified Fission.Web.Log       as Web.Log
import qualified Fission.Web.Types     as Web

import qualified Fission.Platform.Heroku.AddOn.Manifest as Manifest
import           Fission.Platform.Heroku.AddOn.Manifest hiding (id)
import qualified Fission.Platform.Heroku.Types          as Heroku
import qualified Data.Text as Text

main :: IO ()
main = do
  Just manifest <- decodeFileStrict "./addon-manifest.json"

  _processCtx  <- mkDefaultProcessContext
  _host        <- decode .!~ Web.Host "https://runfission.com"
  _ipfsPath    <- decode .!~ IPFS.BinPath "/usr/local/bin/ipfs"
  _ipfsTimeout <- decode .!~ IPFS.Timeout 150
  _pgHost <- withEnv "PG_HOST" "web-api.cn1u7it7btqm.us-east-1.rds.amazonaws.com" Text.pack
  _pgPort <- withEnv "PG_PORT" 5432 (fromInteger . Prelude.read)
  _pgDatabase <- withEnv "PG_DATABASE" "web-api" Text.pack
  _pgSchema <- withEnv "PG_SCHEMA" Nothing (Just . Text.pack)
  _pgUsername <- withEnv "PG_USERNAME" Nothing (Just . Text.pack)
  _pgPassword <- withEnv "PG_PASSWORD" Nothing (Just . Text.pack)
  _pgInfo <- pure $ DB.PGInfo $ PGConnectInfo _pgHost _pgPort _pgDatabase _pgSchema _pgUsername _pgPassword
  _dbPool      <- RIO.runSimpleApp $ PostgreSQL.connPool _pgInfo

  _httpManager <- HTTP.newManager HTTP.defaultManagerSettings
  ipfsURLRaw   <- withEnv "IPFS_URL" "http://localhost:5001" id
  _ipfsURL     <- IPFS.URL <$> parseBaseUrl ipfsURLRaw

  condDebug   <- withFlag "PRETTY_REQS" id logStdoutDev
  isVerbose   <- getFlag "RIO_VERBOSE" .!~ False -- TODO FISSION_VERBOSE or VERBOSE
  logOptions' <- logOptionsHandle stdout isVerbose
  let logOpts = setLogUseTime True logOptions'

  isTLS <- getFlag "TLS" .!~ True
  Web.Port port <- decode .!~ (Web.Port $ if isTLS then 443 else 80)

  withLogFunc logOpts $ \_logFunc -> do
    let
      _herokuID       = Heroku.ID       . encodeUtf8 $ manifest ^. Manifest.id
      _herokuPassword = Heroku.Password . encodeUtf8 $ manifest ^. api ^. password
      config          = Config {..}

    runRIO config do
      condMonitor
      logDebug $ "Servant port is " <> display port
      logDebug $ "TLS is " <> if isTLS then "on" else "off"
      logDebug $ "Configured with: " <> displayShow config

      let runner = if isTLS
                      then runTLS (tlsSettings "domain-crt.txt" "domain-key.txt")
                      else runSettings

      liftIO . runner (Web.Log.mkSettings _logFunc port)
             . CORS.middleware
             . condDebug
             =<< Web.app
             =<< ask

condMonitor :: HasLogFunc cfg => RIO cfg ()
condMonitor = do
  monitorFlag <- liftIO $ getFlag "MONITOR" .!~ False
  when monitorFlag Monitor.wai
