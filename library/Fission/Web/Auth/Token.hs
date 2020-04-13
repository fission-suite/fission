module Fission.Web.Auth.Token
  ( get
  , module Fission.Web.Auth.Token.Types
  ) where

import qualified RIO.ByteString      as BS
import qualified RIO.ByteString.Lazy as Lazy
import           Network.Wai

import           Fission.Prelude
import qualified Fission.Internal.UTF8 as UTF8

import           Fission.Web.Auth.Token.Types
import qualified Fission.Web.Auth.Token.Basic.Types as Basic

get :: Request -> Maybe Token
get req = do
  rawToken <- lookup "Authorization" (requestHeaders req)
  case BS.stripPrefix "Basic " rawToken of
    Just basic' ->
      Just . Basic $ Basic.Token basic'

    Nothing -> do
      let normalizedJSON = "\"" <> UTF8.stripQuotesLazyBS rawToken <> "\""
      Bearer <$> decode' $ Lazy.fromStrict normalizedJSON
