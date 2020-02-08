module Fission.User.Username.Types (Username (..)) where

import           Database.Persist.Class
import           Database.Persist.Types
import           Database.Persist.Sql

import           Data.Swagger
import           Servant

import qualified RIO.ByteString.Lazy as Lazy
import qualified RIO.Text            as Text

import qualified Network.IPFS.Internal.UTF8 as UTF8

import           Fission.Prelude

newtype Username = Username { username :: Text }
  deriving          ( Generic )
  deriving anyclass ( ToParamSchema )
  deriving newtype  ( Show
                    , Eq
                    , IsString
                    , ToHttpApiData
                    )

instance Arbitrary Username where
  arbitrary = Username <$> arbitrary

instance PersistField Username where
  toPersistValue (Username un) = PersistText un
  fromPersistValue = \case
    PersistText un -> Right (Username un)
    other          -> Left ("Invalid Persistent Username: " <> Text.pack (show other))

instance PersistFieldSql Username where
  sqlType _pxy = SqlString

instance ToJSON Username where
  toJSON (Username username) = toJSON (String username)

instance FromJSON Username where
  parseJSON = withText "Username" \txt -> return (Username txt)

instance FromHttpApiData Username where
  parseUrlPiece = Right . Username

instance ToSchema Username where
  declareNamedSchema _ =
    mempty
      |> type_   ?~ SwaggerString
      |> example ?~ "username"
      |> NamedSchema (Just "Username")
      |> pure

instance MimeRender PlainText Username where
  mimeRender _ = UTF8.textToLazyBS . username

instance MimeUnrender PlainText Username where
  mimeUnrender _proxy bs =
    case bs |> Lazy.toStrict |> decodeUtf8' of
      Left err  -> Left  <| show err
      Right txt -> Right <| Username txt
