{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceClientInternal where

import Foreign.C.Types
import Language.Haskell.TH

import Graphics.Wayland.Internal.SpliceClientTypes
import Graphics.Wayland.Scanner

$(runIO readProtocol >>= generateClientInternal)
