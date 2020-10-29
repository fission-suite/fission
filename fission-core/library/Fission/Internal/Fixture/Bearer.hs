{-# OPTIONS_GHC -fno-warn-incomplete-uni-patterns #-}

module Fission.Internal.Fixture.Bearer
  ( jsonRSA2048
  , tokenRSA2048
  , jwtRSA2048
  , rawContent
  , validTime
  ) where

import           Servant.API

import           Fission.Prelude
import qualified Fission.Web.Auth.Token.Bearer.Types         as Bearer
-- import           Fission.Web.Auth.Token.JWT          as JWT
import           Fission.Web.Auth.Token.UCAN.Fact.Types
import           Fission.Web.Auth.Token.UCAN.Privilege.Types
import           Fission.Web.Auth.Token.UCAN.Types

import           Fission.Web.Auth.Token.JWT.RawContent.Types as JWT

validTime :: UTCTime
validTime = fromSeconds 0 -- i.e. waaaay before the expiry :P

rawContent :: JWT.RawContent -- FIXME update with correct new format
rawContent = JWT.RawContent "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsInVhdiI6IjAuMS4wIn0.eyJhdWQiOiJkaWQ6a2V5OnpTdEVacHpTTXRUdDlrMnZzemd2Q3dGNGZMUVFTeUExNVc1QVE0ejNBUjZCeDRlRko1Y3JKRmJ1R3hLbWJtYTQiLCJleHAiOjE1ODgyNjU0MjAsImlzcyI6ImRpZDprZXk6ejFMQm53RWt0d1lMcnBQaHV3Rm93ZFZ3QUZYNXpwUm85cnJWendpUlJCQmlhQm9DUjdoTnFnc3RXN1ZNM1Q5YXVOYnFUbVFXNHZkSGI2MVJoVE1WZ0NwMUJUeHVhS1UzYW5Xb0VSRlhwdVp2ZkUzOWc4dTdIUzlCZUQxUUpOMWZYNlM4dnZza2FQaHhGa3dMdEdyNFpmZmtVRTU3V1pwTldNNlU2QnFka3RaeG1LenhDODV6TjRGQzlXczVMSHVHZnhhQ3VCTGlVZkE3cUVZVlN6MVF1MXJaRHBENk55ZlVOckhKMUVyWmR1SnVuOTc2bmJGSHJtRG5VNDdSY1NNRkVTYk5LRGkxNDY3dFJmdWJzTXJEemViZENGS1EybTFBWXlzdG8yaTZXbWNudWNqdDN0bndUcWU3Qm84TDFnOGg4VUdBOTQ2REYzV2VHYlBVR3F6bnNVZExxNlhMQ21KekprSm1yTnllWmtzd2R5UFgyVnU2SjlFNEoxMlNiM2g5ZHM3YXRCeWFtZnRpdEVac2Y2aFBKa0xVWEdUaFlwQ25tUkFBclJSZlBZMkg2Y0tEYzdBY25GUHlOSEdrYWI1WkZvNHF2Z0JaeXRiSzFLNW9EM0hmUTZFMnliTGh5QzJiOGk1d282REx0bTl1Zml4U0pOTlRIN1Vpa2s4OENtZXJ0S1I3czEyQ0sxV0xFTTNadTVZQlpOcGhuamo3Y3A4UVRvZEFlaFJQVjlORzFDTEVBTUpWTjc5RHZZZTZTZmlhZkpvYmN2ZkQ4bnBmUzZqY2VqY3lvdVFiRXBLREc3UUFuS1M0OFA0QXZnQnFEdmZOVWU1NGpNa2s2cjZDb1g0TGNZR0h1a1pERW5lYTlrd2tFb1hrVVlTNGoxQWZiS2g0NEZ6U3VYYlFxWm5qalZwVGh4Q05tbU5uMUU0cUhtc0ZrdkdvRjNGTjU1Q1Brb0dmREN2eVFKZ3Ftc0ZtcGVUSlN5OXd6djRNdmJxcHVBVHhyN2V5eHNHZUNXUWtjRHd1YjMyaW5HcFIzcmVUZnpSSkVDQ0ZaYXJuWGRjQzVQaWRha2IxV3U4TCIsIm5iZiI6MCwicHRjIjoiQVBQRU5EIiwicHJmIjpudWxsLCJzY3AiOiIvIn0"

jsonRSA2048 :: Text
jsonRSA2048 = "Bearer " <> unRawContent rawContent <> ".fe_x_Z7iR8oOzQK3fC39RwhaFgKXwVQGQHrVoJIfwSHEDZXvtH7fQKS5lc-cgj7Xw508AkjYUf8tEXm6RS223f_ZJHjcf6YwaKQYrJsV7fFfnAB6yYIar7l5bjUTr0yW003wpZLv-WXwGV3AIA7-nqVajLOkgSnCR6NIhF7L9jD-RhVJ-GzqpdKCHHFDQeDgf0twZ4OVpccnZPJSe7st7YzW3p7FhSHnsnFTR5YRflYGDlYH517eSeBAqlludWSlrhnROMObW9B1GFHh_Ye53ougxv31xIlD-OCF13PiiIxJT935w0ttAVfqq7ESiNPuzpUSxqn-Qkp5a-h81UDSxw"

tokenRSA2048 :: Bearer.Token
jwtRSA2048   :: UCAN Privilege Fact

Right tokenRSA2048@(Bearer.Token jwtRSA2048 _) = parseUrlPiece jsonRSA2048
