{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceServerInternal where

import Foreign.C.Types
import Language.Haskell.TH

import Graphics.Wayland.Internal.SpliceServerTypes
import Graphics.Wayland.Internal.Util
import Graphics.Wayland.Scanner

$(runIO readProtocol >>= generateServerInternal)
