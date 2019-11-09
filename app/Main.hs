module Main (main) where

import qualified Data.Aeson as JSON
import qualified Data.Yaml  as YAML

import qualified Network.HTTP.Client as HTTP
import           Network.Wai.Handler.Warp
import           Network.Wai.Handler.WarpTLS
import           Network.Wai.Middleware.RequestLogger

import           Fission.Prelude
import           Fission.Internal.Orphanage.RIO ()
import qualified Fission.Monitor            as Monitor
import           Fission.Storage.PostgreSQL (connPool)

import qualified Fission.Web       as Web
import qualified Fission.Web.CORS  as CORS
import qualified Fission.Web.Log   as Web.Log
import qualified Fission.Web.Types as Web

import qualified Fission.Platform.Heroku.AddOn.Manifest as Hku
import qualified Fission.Platform.Heroku.Types          as Hku

import           Fission.Config.Types
import           Fission.Environment
import           Fission.Environment.Types
import           Fission.IPFS.Environment.Types    as IPFS
import qualified Fission.Storage.Environment.Types as Storage
import qualified Fission.Web.Environment.Types     as Web

import qualified Fission.AWS.Environment.Types as AWS

main :: IO ()
main = do
  Just  manifest <- JSON.decodeFileStrict "./addon-manifest.json"
  env            <- YAML.decodeFileThrow  "./env.yaml"

  let
    Storage.Environment {..} = env |> storage
    Web.Environment     {..} = env |> web
    AWS.Environment     {..} = env |> aws

    herokuID       = Hku.ID       <| encodeUtf8 (manifest |> Hku.id)
    herokuPassword = Hku.Password <| encodeUtf8 (manifest |> Hku.api |> Hku.password)

    ipfsPath    = env |> ipfs |> binPath
    ipfsURL     = env |> ipfs |> url
    ipfsTimeout = env |> ipfs |> IPFS.timeout

    awsAccessKey  = accessKey
    awsSecretKey  = secretKey
    awsZoneID     = zoneID
    awsDomainName = domainName

  dbPool      <- runSimpleApp $ connPool stripeCount connsPerStripe connTTL pgConnectInfo
  processCtx  <- mkDefaultProcessContext
  httpManager <- HTTP.newManager HTTP.defaultManagerSettings
                   { HTTP.managerResponseTimeout = HTTP.responseTimeoutMicro clientTimeout }

  isVerbose    <- getFlag "RIO_VERBOSE" .!~ False
  logOptions   <- logOptionsHandle stdout isVerbose

  withLogFunc (setLogUseTime True logOptions) $ \logFunc -> runRIO Config {..} do
    logDebug . displayShow =<< ask

    let
      Web.Port port' = port
      settings       = mkSettings logFunc port'
      runner         = if env |> web |> Web.isTLS then runTLS tlsSettings' else runSettings
      condDebug      = if env |> web |> Web.pretty then identity else logStdoutDev

    when (env |> web |> Web.monitor) Monitor.wai
    liftIO . runner settings
           . CORS.middleware
           . condDebug
           =<< Web.app

mkSettings :: LogFunc -> Port -> Settings
mkSettings logger port = defaultSettings
                       & setPort port
                       & setLogger (Web.Log.fromLogFunc logger)
                       & setTimeout serverTimeout

tlsSettings' :: TLSSettings
tlsSettings' = tlsSettings "domain-crt.txt" "domain-key.txt"

clientTimeout :: Int
clientTimeout = 1800000000

serverTimeout :: Int
serverTimeout = 1800
