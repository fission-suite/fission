-- | Cryptographic key algorithms

module Fission.Key.Asymmetric.Algorithm.Types (Algorithm (..)) where

import           Data.Swagger
import           Database.Persist.Postgresql

import qualified RIO.Text                    as Text

import           Fission.Prelude

-- | Cryptographic key algorithms (assymmetric)
data Algorithm
  = RSA2048
  | EdDSA
  deriving (Eq, Show)

instance Arbitrary Algorithm where
  arbitrary = elements [RSA2048, EdDSA]

instance ToJSON Algorithm where
  toJSON = String . \case
    RSA2048 -> "RS256" -- Per the JWT Spec (RFC 7519)
    EdDSA -> "Ed25519"

instance FromJSON Algorithm where
  parseJSON = withText "JWT.Algorithm" \case
    "RS256" -> return RSA2048
    "EdDSA" -> return EdDSA
    other   -> fail (Text.unpack other <> " is not a valid JWT algorithm")

instance PersistField Algorithm where
  toPersistValue = \case
    RSA2048 -> PersistText "RSA2048"
    EdDSA   -> PersistText "Ed25519"

  fromPersistValue = \case
    PersistText "RSA2048" -> Right RSA2048
    PersistText "Ed25519" -> Right EdDSA
    other -> Left ("Invalid Persistent public key algorithm: " <> Text.pack (show other))

instance ToSchema Algorithm where
  declareNamedSchema _ =
    mempty
      |> type_ ?~ SwaggerString
      |> NamedSchema (Just "PublicKeyAlgorithm")
      |> pure

instance PersistFieldSql Algorithm where
  sqlType _pxy = SqlString
