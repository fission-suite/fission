-- | Database mutations for 'UserCid's
module Fission.User.CID.Destroyer.Class (Destroyer (..)) where

import Database.Esqueleto
import Network.IPFS.CID.Types as IPFS.CID

import Fission.Prelude
import Fission.Models

-- | Actions for destroying @UserCid@s
class Monad m => Destroyer m where
  -- | Destroy a specific @UserCid@
  destroy :: UserId -> CID -> m ()

  -- | Destroy several @UserCid@s by they primary keys
  destroyX :: [Key UserCid] -> m ()

instance MonadIO m => Destroyer (Transaction m) where
  destroyX :: [Key UserCid] -> Transaction m ()
  destroyX userCidIds =
    Transaction . delete <| from \userCid ->
      where_ (userCid ^. UserCidId `in_` valList userCidIds)

  destroy :: UserId -> CID -> Transaction m ()
  destroy userId cid =
    Transaction . delete <| from \userCid ->
      where_ (selectExact userCid)
    where
      selectExact userCid =
            userCid ^. UserCidCid    ==. val cid
        &&. userCid ^. UserCidUserFk ==. val userId
