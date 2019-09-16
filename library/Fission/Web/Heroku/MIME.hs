module Fission.Web.Heroku.MIME (VendorJSONv3 (..)) where

import RIO

import Data.Aeson
import Network.HTTP.Media ((//), (/:))
import Servant.API

newtype VendorJSONv3 = VendorJSONv3 { unVendorJSONv3 :: Value }
  deriving Show

instance Accept VendorJSONv3 where
  contentType _ = "application" // "vnd.heroku-addons+json" /: ("version", "3")

instance ToJSON a => MimeRender VendorJSONv3 a where
  mimeRender _ = encode

instance FromJSON VendorJSONv3 where
  parseJSON = pure . VendorJSONv3

instance FromJSON a => MimeUnrender VendorJSONv3 a where
  mimeUnrender _ = mimeUnrender (Proxy :: Proxy JSON)