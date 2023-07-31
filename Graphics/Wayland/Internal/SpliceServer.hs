{-# LANGUAGE TemplateHaskell #-}

module Graphics.Wayland.Internal.SpliceServer where

import Language.Haskell.TH

import Graphics.Wayland.Internal.SpliceServerInternal qualified as Import
import Graphics.Wayland.Scanner

$(runIO readProtocol >>= generateServerExports)
