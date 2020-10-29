module Fission.Web.Auth.Token
  ( get
  , handler
  , module Fission.Web.Auth.Token.Types
  ) where

import           Network.Wai
import           Servant.API

import           Fission.Authorization
import           Fission.Prelude
import qualified Fission.User                                as User

import qualified Fission.Web.Auth.Error                      as Auth
import qualified Fission.Web.Auth.Token.Basic                as Basic
import qualified Fission.Web.Auth.Token.UCAN                 as UCAN
import qualified Fission.Web.Error                           as Web.Error

import qualified Fission.Web.Auth.Token.JWT.Resolver         as JWT
import           Fission.Web.Auth.Token.Types

import           Fission.Web.Auth.Token.UCAN.Fact.Types
import           Fission.Web.Auth.Token.UCAN.Privilege.Types
import           Fission.Web.Auth.Token.UCAN.Types

import qualified Fission.Authorization                       as Authorization
import qualified Fission.Web.Auth.Token.Bearer               as UCAN

-- | Higher order auth handler
--   Uses basic auth for "Basic" tokens
--   Uses our custom JWT auth for "Bearer" tokens
handler ::
  ( m `JWT.Resolves` UCAN Privilege Fact
  , ServerDID        m
  , MonadLogger      m
  , MonadThrow       m
  , MonadTime        m
  , MonadDB        t m
  , User.Retriever t
  )
  => Request
  -> m Authorization.Session
handler req =
  case get req of
    Right (Bearer bearer) -> UCAN.handler bearer
    Right (Basic  basic') -> Basic.handler basic'
    Left  err             -> Web.Error.throw err

get :: Request -> Either Auth.Error Token
get req =
  case lookup "Authorization" headers <|> lookup "authorization" headers of
    Nothing ->
      Left Auth.NoToken

    Just auth ->
      case parseHeader auth of
        Left errMsg -> Left $ Auth.CannotParse errMsg
        Right token -> Right token

  where
    headers = requestHeaders req
