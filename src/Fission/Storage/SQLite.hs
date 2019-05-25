{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE DeriveGeneric        #-}
{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE OverloadedStrings    #-}

module Fission.Storage.SQLite
  ( setupTable
  , connPool
  , DBInsertable (..)
  , insert1
  , insertStamp
  , traceAll
  , lensTable
  ) where

import           RIO         hiding     (id)
import qualified RIO.Partial as Partial
import           RIO.Text               (stripPrefix)

import Data.Has
import Data.Pool

import Database.Selda
import Database.Selda.SQLite
import Database.Selda.Backend

import Fission.Internal.Constraint
import Fission.Config

class DBInsertable r where
  insertX :: MonadSelda m
          => UTCTime
          -> [(UTCTime -> UTCTime -> r)]
          -> m (ID r)

insertStamp :: UTCTime -> (UTCTime -> UTCTime -> r) -> r
insertStamp time record = record time time

insert1 :: DBInsertable r
        => MonadSelda m
        => UTCTime
        -> (UTCTime -> UTCTime -> r)
        -> m (ID r)
insert1 t partR = insertX t [partR]

setupTable :: MonadRIO cfg m
           => HasLogFunc cfg
           => Has DBPath cfg
           => Table b
           -> TableName
           -> m ()
setupTable tbl tblName = do
  DBPath db <- view hasLens
  logInfo $ "Creating table `" <> displayShow tblName <> "` in DB " <> displayShow db
  liftIO . withSQLite db $ createTable tbl

-- TODO make configurable
connPool :: HasLogFunc cfg => DBPath -> RIO cfg (Pool SeldaConnection)
connPool (DBPath {unDBPath = path}) = do
  logInfo $ "Establishing database connection for " <> displayShow path

  pool <- liftIO $ createPool (sqliteOpen path) seldaClose 4 2 10
  logInfo $ "DB pool stats: " <> displayShow pool

  return pool

traceAll :: (Show a, Relational a) => Table a -> IO ()
traceAll tbl = withSQLite "fission.sqlite" $ do
  rows <- query (select tbl)
  forM_ rows (traceIO . textDisplay . displayShow)

lensTable :: Relational r => TableName -> [Attr r] -> Table r
lensTable tableName conf =
  tableFieldMod tableName conf (Partial.fromJust . stripPrefix "_")
