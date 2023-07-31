{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceClient where

import Language.Haskell.TH

import Graphics.Wayland.Scanner.Protocol
import Graphics.Wayland.Scanner
import qualified Graphics.Wayland.Internal.SpliceClientInternal as Import

$(runIO readProtocol >>= generateClientExports)
