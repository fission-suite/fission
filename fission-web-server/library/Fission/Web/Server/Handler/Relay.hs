{- | Web Socket Relay

  How this works:

  This handler is invoked per client. It is the connection from the server
  and that user.

  +----------Handler.Relay----------+
  |                                 |
  | Client ---[WebSocket]--- Server |
  |                                 |
  +---------------------------------+

  The internal message routing happens separate from this websocket connection.

  'Relay.setup' grabs the intrenal server channel for the specifid topic (the DID).
  If one didn't exist, it creates an empty one. You now have a producer ("inwards")
  end of a pipe, and a consumer ("outwards") end of a pipe. You push new messages
  into the in-side, which is distributed to everyone. You listen for messages from
  coming off the outwards side of the pipe.

  It also creates a per-user sent-message buffer to avoid sending messages to themselves.
  This variable is kept in the "sendBufferVar".

  When something comes in over this user's websocket connection, we add its hash
  to our sent message buffer, and push it through the channel. It appears for everyone
  listening to the other side(s) of this pipe. If the sender also gets this message,
  they remove it from the set (garbage collection) and noop. Everyone else pushes this
  message through their websocket to the client.

-}
module Fission.Web.Server.Handler.Relay (relay) where

import qualified Network.WebSockets                     as WS
import           Servant

import           Fission.Prelude

import           Fission.Web.Server.Relay               as Relay

import qualified Fission.Web.Server.Handler.Relay.Types as API

relay :: (MonadIO m, MonadLogger m, MonadRelayStore m) => ServerT API.RelayWS m
relay did conn = do
  logDebug $ "Connected to user link for " <> textDisplay did
  storeVar <- getStoreVar
  (sentBufferVar, chanIn, chanOut) <- atomically $ Relay.setup did storeVar

  liftIO $ WS.withPingThread conn 30 noop do
    concurrently_
      (inbound  conn chanIn  sentBufferVar)
      (outbound conn chanOut sentBufferVar)
