module Fission.Web.IPFS.Pin
  ( API
  , server
  , pin
  , unpin
  ) where

import RIO
import RIO.Process (HasProcessContext)

import Data.Has
import Database.Selda
import Servant

import qualified Fission.IPFS.Types   as IPFS
import qualified Fission.Storage.IPFS as Storage.IPFS
import qualified Fission.Web.Error    as Web.Err
import           Fission.Web.Server
import           Fission.IPFS.CID.Types
import qualified Fission.User.CID     as UserCID
import           Fission.User

type API = PinAPI :<|> UnpinAPI

type PinAPI = Capture "cid" CID
           :> Put '[PlainText, OctetStream] NoContent

type UnpinAPI = Capture "cid" CID
             :> Delete '[PlainText, OctetStream] NoContent

server :: Has IPFS.BinPath  cfg
       => HasProcessContext cfg
       => MonadSelda   (RIO cfg)
       => HasLogFunc        cfg
       => User
       -> RIOServer         cfg API
server User { _userID } = pin _userID :<|> unpin _userID

pin :: Has IPFS.BinPath  cfg
    => HasProcessContext cfg
    => MonadSelda   (RIO cfg)
    => HasLogFunc        cfg
    => ID User
    -> RIOServer         cfg PinAPI
pin uID cid = Storage.IPFS.pin cid >>= \case
  Left err -> Web.Err.throw err
  Right ()  -> do
    -- FIXME check if already exists for this user
    void $ UserCID.createFresh uID cid
    return NoContent

unpin :: Has IPFS.BinPath  cfg
      => HasProcessContext cfg
      => HasLogFunc        cfg
      => MonadSelda   (RIO cfg)
      => ID User
      -> RIOServer         cfg UnpinAPI
unpin uID cid = transaction do
  -- delete userCID
  -- lookup how many refs to that CID remain
  -- if 0, then unpin, else noop

   deleteFrom userCIDs $ \ucid ->
     ucid ! #id .== just ...

  -- Storage.IPFS.unpin cid >>= \case
  -- Left err -> Web.Err.throw err
  -- Right ()  -> do
  --   void $ UserCID.createFresh uID cid
  --   pure NoContent
