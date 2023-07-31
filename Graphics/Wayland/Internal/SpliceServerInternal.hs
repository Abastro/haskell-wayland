{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceServerInternal where

import Language.Haskell.TH
import Foreign.C.Types

import Graphics.Wayland.Scanner.Protocol
import Graphics.Wayland.Scanner
import Graphics.Wayland.Internal.Util
import Graphics.Wayland.Internal.SpliceServerTypes


$(runIO readProtocol >>= generateServerInternal)
