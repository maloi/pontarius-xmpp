{-# Language OverloadedStrings, ViewPatterns, NoMonomorphismRestriction #-}

module Network.XMPP.Marshal where

import Control.Applicative((<$>))

import Data.Maybe
import Data.Text(Text)

import Data.XML.Types
import Data.XML.Pickle

import qualified Data.Text as Text

import Network.XMPP.Pickle
import Network.XMPP.Types


stanzaSel (SMessage  _) = 0
stanzaSel (SPresence _) = 1
stanzaSel (SIQ       _) = 2

stanzaP :: PU [Node] Stanza
stanzaP = xpAlt stanzaSel
               [ xpWrap SMessage   (\(SMessage  m) -> m) messageP
               , xpWrap SPresence  (\(SPresence p) -> p) presenceP
               , xpWrap SIQ        (\(SIQ       i) -> i) iqP
               ]

messageP :: PU [Node] Message
messageP = xpWrap   (\((from, to, id, tp),(sub, body, thr,ext))
                             -> Message from to id tp sub body thr ext)
                    (\(Message from to id tp sub body thr ext)
                             -> ((from, to, id, tp), (sub, body, thr,ext)))
                    $
           xpElem "{jabber:client}message"
             (xp4Tuple
               (xpAttrImplied "from" xpPrim)
               (xpAttr        "to"   xpPrim)
               (xpAttrImplied "id"   xpId)
               (xpAttrImplied "type" xpPrim)
             )
             (xp4Tuple
               (xpOption . xpElemNodes "{jabber:client}subject" $ xpContent xpId)
               (xpOption . xpElemNodes "{jabber:client}body" $ xpContent xpId)
               (xpOption . xpElemNodes "{jabber:client}thread" $ xpContent xpId)
               (xpAll xpElemVerbatim)
             )

presenceP :: PU [Node] Presence
presenceP = xpWrap   (\((from, to, id, tp),(shw, stat, prio, ext))
                             -> Presence from to id tp shw stat prio ext)
                     (\(Presence from to id tp shw stat prio ext)
                             -> ((from, to, id, tp), (shw, stat, prio, ext)))
                     $
           xpElem "{jabber:client}presence"
             (xp4Tuple
               (xpAttrImplied "from" xpPrim)
               (xpAttrImplied "to"   xpPrim)
               (xpAttrImplied "id"   xpId)
               (xpAttrImplied "type" xpPrim)
             )
             (xp4Tuple
               (xpOption . xpElemNodes "{jabber:client}show" $ xpContent xpPrim)
               (xpOption . xpElemNodes "{jabber:client}status" $ xpContent xpId)
               (xpOption . xpElemNodes "{jabber:client}priority" $ xpContent xpPrim)
               (xpAll xpElemVerbatim)
             )

iqP :: PU [Node] IQ
iqP = xpWrap  (\((from, to, id, tp),body) -> IQ from to id tp body)
              (\(IQ from to id tp body) -> ((from, to, id, tp), body))
              $
           xpElem "{jabber:client}iq"
             (xp4Tuple
               (xpAttrImplied "from" xpPrim)
               (xpAttrImplied "to"   xpPrim)
               (xpAttr        "id"   xpId)
               ((xpAttr        "type" xpPrim) :: PU [(Name,[Content])] IQType)
             )
             (xpElemVerbatim)

