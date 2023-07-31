{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceClient where

import Language.Haskell.TH

import Graphics.Wayland.Internal.SpliceClientInternal qualified as Import
import Graphics.Wayland.Scanner

$(runIO readProtocol >>= generateClientExports)
