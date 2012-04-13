-- Copyright © 2010-2012 Jon Kristensen.
-- Copyright 2012 Philipp Balzarek
-- See the LICENSE file in the
-- Pontarius distribution for more details.

-- |
-- Module:      $Header$
-- Description: Pontarius API
-- Copyright:   Copyright © 2010-2012 Jon Kristensen
-- License:     Apache License 2.0
--
-- Maintainer:  jon.kristensen@nejla.com
-- Stability:   unstable
-- Portability: portable
--
-- XMPP is an open standard, extendable, and secure communications
-- protocol designed on top of XML, TLS, and SASL. Pontarius XMPP is
-- an XMPP client library, implementing the core capabilities of XMPP
-- (RFC 6120).
--
-- Developers using this library are assumed to understand how XMPP
-- works.
--
-- This module will be documented soon.
--
-- Note that we are not recommending anyone to use Pontarius XMPP at
-- this time as it's still in an experimental stage and will have its
-- API and data types modified frequently.

{-# LANGUAGE NoMonomorphismRestriction, OverloadedStrings  #-}

module Network.XMPP
  ( module Network.XMPP.Bind
  , module Network.XMPP.Concurrent
  , module Network.XMPP.Monad
  , module Network.XMPP.SASL
  , module Network.XMPP.Session
  , module Network.XMPP.Stream
  , module Network.XMPP.TLS
  , module Network.XMPP.Types
  , module Network.XMPP.Presence
  , module Network.XMPP.Message
--  , connectXMPP
  , sessionConnect
  ) where

import Data.Text as Text

import Network
import Network.XMPP.Bind
import Network.XMPP.Concurrent
import Network.XMPP.Message
import Network.XMPP.Monad
import Network.XMPP.Presence
import Network.XMPP.SASL
import Network.XMPP.Session
import Network.XMPP.Stream
import Network.XMPP.TLS
import Network.XMPP.Types

import System.IO

--fromHandle :: Handle -> Text -> Text -> Maybe Text -> Text -> IO ((), XMPPState)
-- fromHandle :: Handle -> Text -> Text -> Maybe Text -> Text -> XMPPThread a
--             -> IO ((), XMPPState)
-- fromHandle handle hostname username rsrc password a =
--   xmppFromHandle handle hostname username rsrc $ do
--       xmppStartStream
--       -- this will check whether the server supports tls
--       -- on it's own
--       xmppStartTLS exampleParams
--       xmppSASL password
--       xmppBind rsrc
--       xmppSession
--       _ <- runThreaded a
--       return ()

-- connectXMPP  :: HostName -> Text -> Text -> Maybe Text
--                 -> Text -> XMPPThread a -> IO ((), XMPPState)
-- connectXMPP host hostname username rsrc passwd a = do
--   con <- connectTo host (PortNumber 5222)
--   hSetBuffering con NoBuffering
--   fromHandle con hostname username rsrc passwd a

sessionConnect  :: HostName -> Text -> Text
                   -> Maybe Text -> XMPPThread a -> IO (a, XMPPConState)
sessionConnect host hostname username rsrc a = do
  con <- connectTo host (PortNumber 5222)
  hSetBuffering con NoBuffering
  xmppFromHandle con hostname username rsrc $
    xmppStartStream >> runThreaded a

