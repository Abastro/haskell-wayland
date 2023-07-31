module Graphics.Wayland (
  version,
  Fixed256,
  Precision256,
  Time,
  Result (..),
  errToResult,
  diffTimeToTime,
  timeToDiffTime,
  ProtocolVersion (..),
  scannedVersionOf,
) where

import Data.Proxy
import Foreign.C.Types

import Graphics.Wayland.Internal.Util
import Graphics.Wayland.Internal.Version

data Result = Success | Failure deriving (Eq, Show)
errToResult :: CInt -> Result
errToResult = \case
  0 -> Success
  -1 -> Failure
  _ -> error "invalid input"

class ProtocolVersion a where
  protocolVersion :: Proxy a -> Int

scannedVersionOf :: forall a. (ProtocolVersion a) => a -> Int
scannedVersionOf _ = protocolVersion (Proxy :: Proxy a)
