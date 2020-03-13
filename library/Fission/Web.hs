-- | Top level web application and API
module Fission.Web
  ( API
  , app
  , server
  , bizServer
  ) where

import           Network.IPFS
import           Servant

import           Fission.Prelude

import           Fission.Internal.Orphanage.OctetStream ()
import           Fission.Internal.Orphanage.PlainText   ()

import           Fission.IPFS.DNSLink as DNSLink
import           Fission.IPFS.Linked

import           Fission.Web.Handler
import           Fission.Web.Server.Reflective

import qualified Fission.App.Creator.Class   as App
import qualified Fission.App.Destroyer.Class as App

import qualified Fission.User                  as User
import qualified Fission.LoosePin              as LoosePin
import qualified Fission.Platform.Heroku.AddOn as Heroku.AddOn

import qualified Fission.Web.Auth    as Auth
import qualified Fission.Web.DNS     as DNS
import qualified Fission.Web.Heroku  as Heroku
import qualified Fission.Web.IPFS    as IPFS
import qualified Fission.Web.Ping    as Ping
import qualified Fission.Web.Routes  as Web
import qualified Fission.Web.Swagger as Web.Swagger
import qualified Fission.Web.Types   as Web
import qualified Fission.Web.User    as User
import qualified Fission.Web.App     as App

-- | Top level web API type. Handled by 'server'.
type API = Web.Swagger.API :<|> Web.API

app ::
  ( MonadReflectiveServer m
  , MonadLinkedIPFS       m
  , MonadRemoteIPFS       m
  , MonadLocalIPFS        m
  , MonadDNSLink          m
  , MonadLogger           m
  , MonadTime             m
  , MonadDB             t m
  , MonadLogger         t
  , MonadThrow          t
  , Heroku.AddOn.CRUD   t
  , User.CRUD           t
  , LoosePin.CRUD       t
  , App.Creator         t
  , App.Destroyer       t
  )
  => (forall a . m a -> Handler a)
  -> Context Auth.Checks
  -> Web.Host
  -> Application
app handlerNT authChecks appHost = do
  appHost
    |> server
    |> Auth.authWithContext api handlerNT
    |> serveWithContext     api authChecks
  where
    api = Proxy @API

-- | Web handlers for the 'API'
server ::
  ( MonadReflectiveServer m
  , MonadLinkedIPFS       m
  , MonadRemoteIPFS       m
  , MonadLocalIPFS        m
  , MonadDNSLink          m
  , MonadLogger           m
  , MonadTime             m
  , MonadDB             t m
  , MonadLogger         t
  , MonadThrow          t
  , Heroku.AddOn.CRUD   t
  , User.CRUD           t
  , LoosePin.CRUD       t
  , App.Creator         t
  , App.Destroyer       t
  )
  => Web.Host
  -> ServerT API m
server appHost = Web.Swagger.server fromHandler appHost
            :<|> bizServer

bizServer ::
  ( MonadReflectiveServer m
  , MonadLinkedIPFS       m
  , MonadRemoteIPFS       m
  , MonadLocalIPFS        m
  , MonadDNSLink          m
  , MonadLogger           m
  , MonadTime             m
  , MonadDB             t m
  , MonadLogger         t
  , MonadThrow          t
  , Heroku.AddOn.CRUD   t
  , User.CRUD           t
  , LoosePin.CRUD       t
  , App.Creator         t
  , App.Destroyer       t
  )
  => ServerT Web.API m
bizServer = IPFS.server
       :<|> App.server
       :<|> (\_ -> Heroku.server)
       :<|> User.server
       :<|> pure Ping.pong
       :<|> DNS.server
