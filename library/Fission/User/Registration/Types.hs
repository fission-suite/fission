module Fission.User.Registration.Types ( Registration(..) ) where

import Data.Swagger hiding (email)

import Fission.Prelude

data Registration = Registration
  { username :: !Text
  , password :: !Text
  , email    :: !(Maybe Text)
  }

instance ToJSON Registration where
  toJSON (Registration username' password' maybeEmail) =
    Object [ ("username", String username')
           , ("password", String password')
           , ("email", maybe Null String maybeEmail)
           ]

instance FromJSON Registration where
  parseJSON = withObject "Registration" \obj -> do
    username <- obj .:  "username"
    password <- obj .:  "password"
    email    <- obj .:? "email"

    return <| Registration {..}

instance ToSchema Registration where
  declareNamedSchema _ = do
    username' <- declareSchemaRef <| Proxy @Text
    password' <- declareSchemaRef <| Proxy @Text
    email'    <- declareSchemaRef <| Proxy @Text

    mempty
      |> type_      ?~ SwaggerObject
      |> properties .~
           [ ("username", username')
           , ("password", password')
           , ("email", email')
           ]
      |> required .~ ["username", "password"]
      |> description ?~
           "The information that a user needs to provide to login/register."
      |> example ?~ toJSON Registration
           { username = "username"
           , password = "password123!"
           , email    = Just "alice@example.com"
           }
      |> NamedSchema (Just "Registration")
      |> pure
