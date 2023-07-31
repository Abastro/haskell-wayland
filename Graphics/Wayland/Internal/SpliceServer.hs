{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceServer where

import Language.Haskell.TH

import Graphics.Wayland.Scanner.Protocol
import Graphics.Wayland.Scanner
import qualified Graphics.Wayland.Internal.SpliceServerInternal as Import

$(runIO readProtocol >>= generateServerExports)
