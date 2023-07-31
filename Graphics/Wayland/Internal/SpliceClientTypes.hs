{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceClientTypes where

import Language.Haskell.TH

import Graphics.Wayland.Scanner

$(runIO readProtocol >>= generateClientTypes)
