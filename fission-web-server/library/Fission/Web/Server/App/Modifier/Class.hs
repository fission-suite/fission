module Fission.Web.Server.App.Modifier.Class
  ( Modifier (..)
  , Errors'
  ) where

import qualified Network.IPFS.Add.Error                             as IPFS.Pin
import           Network.IPFS.CID.Types
import qualified Network.IPFS.Get.Error                             as IPFS.Stat

import           Servant.Server

import           Fission.Prelude                                    hiding (on)

import           Fission.Error                                      as Error
import           Fission.URL

import           Fission.Web.Server.Error.ActionNotAuthorized.Types
import qualified Fission.Web.Server.Internal.NGINX.Purge            as NGINX
import           Fission.Web.Server.Models

type Errors' = OpenUnion
  '[ NotFound App
   , NotFound AppDomain
   , NotFound Domain
   , NotFound URL

   , ActionNotAuthorized App
   , ActionNotAuthorized AppDomain
   , ActionNotAuthorized URL

   , IPFS.Pin.Error
   , IPFS.Stat.Error

   , NGINX.BatchErrors

   , ServerError
   , InvalidURL
   ]

class Monad m => Modifier m where
  setCID ::
       UserId  -- ^ User for auth
    -> URL     -- ^ URL associated with target app
    -> CID     -- ^ New CID
    -> Bool    -- ^ Flag: copy data (default yes)
    -> UTCTime -- ^ Now
    -> m (Either Errors' AppId)
