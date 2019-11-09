-- | App configuration for AWS
module Fission.AWS.Environment.Types (Environment (..)) where

import qualified Network.AWS.Auth  as AWS
import           RIO.List (intercalate)

import           Fission.Prelude
import qualified Fission.AWS.Types as AWS
import           Fission.Internal.Orphanage.PGConnectInfo ()

data Environment = Environment
  { accessKey  :: !AWS.AccessKey  -- ^ Access Key
  , secretKey  :: !AWS.SecretKey  -- ^ Secret Key
  , zoneID     :: !AWS.ZoneID     -- ^ Hosted Zone
  , domainName :: !AWS.DomainName -- ^ Domain Name
  }

instance Show Environment where
  show Environment {..} = intercalate "\n"
    [ "Environment {"
    , "  accessKey  = " <> show accessKey
    , "  secretKey  = HIDDEN"
    , "  zoneId     = " <> show zoneID
    , "  domainName = " <> show domainName
    , "}"
    ]

instance FromJSON Environment where
  parseJSON = withObject "AWS.Environment" \obj -> do
    accessKey  <- obj .: "access_key"
    secretKey  <- obj .: "secret_key"
    zoneID     <- obj .: "zone_id"
    domainName <- obj .: "domain_name"

    return $ Environment {..}
