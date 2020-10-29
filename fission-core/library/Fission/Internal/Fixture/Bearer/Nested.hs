{-# OPTIONS_GHC -fno-warn-incomplete-uni-patterns #-}

-- | A real world example with a nested proof
module Fission.Internal.Fixture.Bearer.Nested
  ( jsonRSA2048
  , tokenRSA2048
  , jwtRSA2048
  , rawContent
  , validTime
  , InTimeBounds (..)
  ) where

import           Servant.API


import           Fission.Authorization.ServerDID.Class
import qualified Fission.Internal.Time                       as Time
import           Fission.Prelude

import qualified Fission.Web.Auth.Token.Bearer.Types         as Bearer
-- import           Fission.Web.Auth.Token.JWT.Types            as JWTo

import           Fission.Web.Auth.Token.UCAN.Fact.Types
import           Fission.Web.Auth.Token.UCAN.Privilege.Types
import           Fission.Web.Auth.Token.UCAN.Types

import           Fission.Web.Auth.Token.JWT.RawContent.Types as JWT

import           Fission.Web.Auth.Token.JWT.Resolver         as Proof

newtype InTimeBounds a = InTimeBounds { unwrap :: Identity a }
  deriving newtype
    ( Functor
    , Applicative
    , Monad
    , Eq
    , Show
    )

instance InTimeBounds `Proof.Resolves` jwt where
  resolve = error "shouldn't hit this in our specific case"

instance ServerDID InTimeBounds where
  getServerDID = pure did
    where
      Right did = eitherDecode "\"did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4\""

instance MonadTime InTimeBounds where
  currentTime = pure $ Time.fromSeconds 1591627760

validTime :: UTCTime
validTime = fromSeconds 0 -- i.e. waaaay before the expiry :P

rawContent :: JWT.RawContent
rawContent = JWT.RawContent "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsInVhdiI6IjAuMS4wIn0.eyJhdWQiOiJkaWQ6a2V5OnpTdEVacHpTTXRUdDlrMnZzemd2Q3dGNGZMUVFTeUExNVc1QVE0ejNBUjZCeDRlRko1Y3JKRmJ1R3hLbWJtYTQiLCJleHAiOjE1OTE2Mjc4NDEsImlzcyI6ImRpZDprZXk6ejEzVjNTb2cyWWFVS2hkR0NtZ3g5VVp1VzFvMVNoRkpZYzZEdkdZZTdOVHQ2ODlOb0wzazdIdXdCUXhKZFBqdllURHhFd3kxbTh3YjZwOTRjNm1NWTRmTnFBV0RkeVk3NVNWMnFEODVLNU1ZcVpqYUpZOGM0NzFBUEZydkpTZEo1QXo1REVDaENnV0xOdkVYRjJxaFlSMkZWaVprVGhvRVB0Mk5ZcHVxZ0txZVZvS1RpZkRpd3JYeUhka3hCazJNOWNQZE5HaGczRE0xWTZyVGY2RDJIZ2JlUnF2OGtvVW9xeWlLTWpYYUZTZlFZVkY3cGZGWGhOYWdKRGZqcG9xQ3FWWFllaTFQbU43UzM0cFdvcTZwUmRQczY5N2F4VVRFNXZQeXNlU3ROc3o4SGFqdUp2NzlDSENNZ2RvRkJzOXc3UHZNSFVEeGdHUWR0c3hBQXZKRzRxVGJkU0I2bUd2TFp0cGE5czFNemNIcDVEV1NjaUJxNnF1aG1SSHRTVFdHNW9FSnRTdlN4QlhTczJoZFBId0I0QVUiLCJuYmYiOjE1OTE2Mjc3NTEsInByZiI6ImV5SmhiR2NpT2lKU1V6STFOaUlzSW5SNWNDSTZJa3BYVkNJc0luVmhkaUk2SWpBdU1TNHdJbjAuZXlKaGRXUWlPaUprYVdRNmEyVjVPbm94TTFZelUyOW5NbGxoVlV0b1pFZERiV2Q0T1ZWYWRWY3hiekZUYUVaS1dXTTJSSFpIV1dVM1RsUjBOamc1VG05TU0yczNTSFYzUWxGNFNtUlFhblpaVkVSNFJYZDVNVzA0ZDJJMmNEazBZelp0VFZrMFprNXhRVmRFWkhsWk56VlRWakp4UkRnMVN6Vk5XWEZhYW1GS1dUaGpORGN4UVZCR2NuWktVMlJLTlVGNk5VUkZRMmhEWjFkTVRuWkZXRVl5Y1doWlVqSkdWbWxhYTFSb2IwVlFkREpPV1hCMWNXZExjV1ZXYjB0VWFXWkVhWGR5V0hsSVpHdDRRbXN5VFRsalVHUk9SMmhuTTBSTk1WazJjbFJtTmtReVNHZGlaVkp4ZGpocmIxVnZjWGxwUzAxcVdHRkdVMlpSV1ZaR04zQm1SbGhvVG1GblNrUm1hbkJ2Y1VOeFZsaFpaV2t4VUcxT04xTXpOSEJYYjNFMmNGSmtVSE0yT1RkaGVGVlVSVFYyVUhselpWTjBUbk42T0VoaGFuVktkamM1UTBoRFRXZGtiMFpDY3psM04xQjJUVWhWUkhoblIxRmtkSE40UVVGMlNrYzBjVlJpWkZOQ05tMUhka3hhZEhCaE9YTXhUWHBqU0hBMVJGZFRZMmxDY1RaeGRXaHRVa2gwVTFSWFJ6VnZSVXAwVTNaVGVFSllVM015YUdSUVNIZENORUZWSWl3aVpYaHdJam94TlRrME1qRTVOelE0TENKcGMzTWlPaUprYVdRNmEyVjVPbm94TTFZelUyOW5NbGxoVlV0b1pFZERiV2Q0T1ZWYWRWY3hiekZUYUVaS1dXTTJSSFpIV1dVM1RsUjBOamc1VG05TU0wWjFRVlIwVlZCV1p6ZHBXRGQ0YlUxdGNrbzJNVE0wVkcxaE1tSkdWWE5YVVhreVRtUkhTREZYYVRSSWVVNWhOemh3VG0xU1RrRkdVRWhHU21KcVNqRnhZemc0TkZoeE1XbHlhV2wwY1ZKVk0zQmtkRVJSVFhobmIyRjNNVUptVFZkRlRVWnJkVmxWUm5Gd1JFdGlSMHd6WTNKQ2VtNUxkbFpNZDJsRGExQkhiM2h0V0VGWE4waFZOemw2TmxCVVRVZDVVMHRDUlVGMVdERjNSVE0wTlRKQ05rbzVOblphZFc5aVJUTlpZVUV5T0hsTFMwaE1OV2xxWmtKVVJFVTFaRTF6TmpWaFJraGlSbVZUZDNONlJtMWxkVkZxTkdkS1JEVklaMUJOYjI1bGRHZzNUSFZIWlhVMFlWVldWMFZDVkZKdk5sWmlTbFpRTVdKSVNqZHhUbUZRWW1JMFNrUjRTa2hFUkhaeFV6Vm9PRlJCZFZVMmIweFNUa1ZuTTJSdU4xSnBjV295VW1ST1ZYbFRkbkZxVkU0MWQzUk1VMjl3ZGtSNlFVSXllbFl5VUhSYWNETjJNVEZPYjJaRWEyNTJSWFpYYTBONmRYbFdRVnA1VFVGbk9HZGFXa2RESWl3aWJtSm1Jam94TlRreE5qSTNOamc0TENKd2RHTWlPaUpCVUZCRlRrUWlMQ0p6WTNBaU9pSXZJbjAuZWFIcmZuaFJkdy1ob1B3Q2RjVXpTX09abm5VXzFIR3RwU0JHenM1SmtDcGs5RlVQZVYwU2xVbF9kUkI0UzZ0M2xnbi14UHVoaVA3WE5kMGM3Qm9hZFd0SkxMSlY4VV9MZ2pUUUdMa1h4al9yVTZrYXA4bFRibllneDZPZzFiZi10bUhlVVVCNFZOY2RFUGlTMFRUYllMZlFDN05rLTZzbWkwekNYQlVBd1JrLURSQURtdkdhMzloVzFMQlFqWl9oejVhOVRYTTlRb0drS0szQkxDM2JVbXFKU1Y0SjVCTmlxanQ0TktqOUo1RjVYYjdHNTd4MkttWkVMYUw1U2NYV1lvWmpxVlJNWF9MY3k1WE4xaUJvWmFHVHlFbzlVNVBNYzhRSVRoaEdQTXNtc2JTS1cxc1AyUFF6OGNOUHh5b2NXYmZsT0dQZkVGZ21aenk4RGwxTkN3IiwicHRjIjoiQVBQRU5EIiwic2NwIjoiLyJ9"

jsonRSA2048 :: Text
jsonRSA2048 = "Bearer " <> unRawContent rawContent <> ".Q7dBT4vbz9tgWlLgGgex-sk69immscmpvz-r7TQfxgIsJUBwLiWk0q0mxW5l1In2x_HU_Q42N9C5XOnoYwauPGsjOmtisGNtWCzNuUWDPdHfcBVcg1CEFt0FtTr2zM0WT7TaiWh6WK5J16G3Sf1Nd2uxWCXYIMZWng7lvbKqOY-ME0M4eIHQ6gh1oS45rQhvxQ33NS8p17mET3KvZ3OlQVXsk641N8tSJPgJv-Y4Io5b4HpiYWO9Z2E4N_r4DkexW3D8ztdcBtCVIqPVjOKtA63jX1cFaqU7Rs0z_KpvPlQqOh4BQeI1AjGSrgnckmIgMFn11Dx98DsxwIxN8NrD_g"

tokenRSA2048 :: Bearer.Token
jwtRSA2048   :: UCAN Privilege Fact

Right tokenRSA2048@(Bearer.Token jwtRSA2048 _) = parseUrlPiece jsonRSA2048
