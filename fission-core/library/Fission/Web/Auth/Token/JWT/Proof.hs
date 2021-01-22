module Fission.Web.Auth.Token.JWT.Proof
  ( delegatedInBounds
  , signaturesMatch
  , resourceInSubset
  , potencyInSubset
  , containsFact

  -- * Reexport

  , module Fission.Web.Auth.Token.JWT.Proof.Error
  ) where

import qualified RIO.List                                         as List

import           Fission.Prelude

import           Fission.Web.Auth.Token.JWT.Fact.Types
import           Fission.Web.Auth.Token.JWT.Proof.Error
import           Fission.Web.Auth.Token.JWT.Types                 as JWT

import           Fission.Web.Auth.Token.UCAN.Resource.Scope.Types
import           Fission.Web.Auth.Token.UCAN.Resource.Types

delegatedInBounds :: JWT -> JWT -> Either Error JWT
delegatedInBounds  jwt prfJWT = do
  signaturesMatch  jwt prfJWT
  resourceInSubset jwt prfJWT
  potencyInSubset  jwt prfJWT
  timeInSubset     jwt prfJWT

signaturesMatch :: JWT -> JWT -> Either Error JWT
signaturesMatch jwt prfJWT =
  if (jwt |> claims |> sender) == (prfJWT |> claims |> receiver)
    then Right jwt
    else Left InvalidSignatureChain

resourceInSubset :: JWT -> JWT -> Either Error JWT
resourceInSubset jwt prfJWT =
  case ((jwt |> claims |> resource), (prfJWT |> claims |> resource)) of
    (Just (Subset (FissionFileSystem path)), Just (Subset (FissionFileSystem proofPath))) ->
      if path `List.isPrefixOf` proofPath -- NOTE `List` because FilePath ~ String
        then Right jwt
        else Left ScopeOutOfBounds

    (a, b) ->
      if a == b
        then Right jwt
        else Left ScopeOutOfBounds

potencyInSubset :: JWT -> JWT -> Either Error JWT
potencyInSubset jwt prfJWT =
  if (jwt |> claims |> potency) <= (prfJWT |> claims |> potency)
    then Right jwt
    else Left PotencyEscelation

timeInSubset :: JWT -> JWT -> Either Error JWT
timeInSubset jwt prfJWT =
  if startBoundry && expiryBoundry
    then Right jwt
    else Left TimeNotSubset

  where
    startBoundry  = (jwt |> claims |> nbf) >= (prfJWT |> claims |> nbf)
    expiryBoundry = (jwt |> claims |> exp) <= (prfJWT |> claims |> exp)

containsFact :: JWT -> ([Fact] -> Either Error ()) -> Either Error JWT
containsFact jwt factChecker =
  jwt
    |> claims
    |> facts
    |> factChecker
    |> \case
        Left err -> Left err
        Right () -> Right jwt
