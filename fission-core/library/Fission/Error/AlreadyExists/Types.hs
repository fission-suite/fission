{-# LANGUAGE UndecidableInstances #-}

module Fission.Error.AlreadyExists.Types (AlreadyExists (..)) where

import qualified Crypto.PubKey.Ed25519               as Ed25519
import           Servant

import           Fission.Prelude

import           Fission.Models
import           Fission.Web.Error                   as Error

import           Fission.User.Username.Types

import           Fission.Key.Asymmetric.Public.Types as Key

data AlreadyExists entity
  = AlreadyExists
  deriving ( Show
           , Eq
           , Exception
           )

instance Display (AlreadyExists entity) => ToServerError (AlreadyExists entity) where
  toServerError alreadyExists = Error.withMessage alreadyExists err409

instance Display (AlreadyExists User) where
  display _ = "User already exists"

instance Display (AlreadyExists Username) where
  display _ = "Username already exists"

instance Display (AlreadyExists UserChallenge) where
  display _ = "Challenge already exists"

instance Display (AlreadyExists LoosePin) where
  display _ = "Loose pin already exists"

instance Display (AlreadyExists Domain) where
  display _ = "Domain already exists"

instance Display (AlreadyExists App) where
  display _ = "App already exists"

instance Display (AlreadyExists HerokuAddOn) where
  display _ = "Heroku add-on already exists"

instance Display (AlreadyExists Ed25519.SecretKey) where
  display _ = "Ed25519 secret key already exists"

instance Display (AlreadyExists Key.Public) where
  display _ = "Public key already exists"
