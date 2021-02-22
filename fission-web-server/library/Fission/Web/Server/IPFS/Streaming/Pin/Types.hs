module Fission.Web.Server.IPFS.Streaming.Pin.Types
  ( PinComplete
  , PinStatus (..)
  ) where

import           Network.IPFS.CID.Types
import           Servant.API

import           Fission.Prelude

type PinComplete
  =  "api"
  :> "v0"
  :> "pin"
  :> "add"
  :> QueryParam "arg"      CID
  :> QueryParam "progress" Bool
  :> StreamPost NewlineFraming JSON (SourceIO PinStatus)

data PinStatus = PinStatus
  { pins     :: [CID]
  , progress :: Maybe Natural
  }
  deriving (Eq, Show)

instance Display PinStatus where
  display status = displayShow status

instance FromJSON PinStatus where
  parseJSON = withObject "IPFS.PinStatus" \obj -> do
    pins     <- obj .:? "Pins"     .!= []
    progress <- obj .:? "Progress"
    return PinStatus {..}
