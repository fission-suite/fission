module Fission.Web.User.UpdateExchangeKeys
  ( API
  , AddAPI
  , RemoveAPI
  , server
  , addKey
  , removeKey
  ) where

import           Servant

import           Fission.Prelude

import qualified Fission.Authorization                      as Authorization
import           Fission.Models
import           Fission.Web.Auth.Token.UCAN.Resource.Types

import qualified Fission.User                               as User
import qualified Fission.Web.Error                          as Web.Error

import qualified Crypto.PubKey.RSA                          as RSA

type API = AddAPI :<|> RemoveAPI

type AddAPI
  =  Summary "Add Public Exchange Key"
  :> Description "Add a key to the currently authenticated user's root list of public exchange keys"
  :> Capture "did" RSA.PublicKey
  :> Put     '[JSON] [RSA.PublicKey]

type RemoveAPI
  =  Summary "Remove Public Exchange Key"
  :> Description "Remove a key from the currently authenticated user's root list of public exchange keys"
  :> Capture "did" RSA.PublicKey
  :> Delete  '[JSON] [RSA.PublicKey]

server ::
  ( MonadTime     m
  , MonadLogger   m
  , MonadThrow    m
  , User.Modifier m
  )
  => Authorization.Session
  -> ServerT API m
server Authorization.Session {} = do
-- server Authorization {about = Entity userId _} =
  let userId = undefined
  addKey userId :<|> removeKey userId

addKey ::
  ( MonadTime     m
  , MonadLogger   m
  , MonadThrow    m
  , User.Modifier m
  )
  => UserId
  -> ServerT AddAPI m
addKey userId key = do
  now <- currentTime
  Web.Error.ensureM $ User.addExchangeKey userId key now

removeKey ::
  ( MonadTime     m
  , MonadLogger   m
  , MonadThrow    m
  , User.Modifier m
  )
  => UserId
  -> ServerT RemoveAPI m
removeKey userId key = do
  now <- currentTime
  Web.Error.ensureM $ User.removeExchangeKey userId key now
