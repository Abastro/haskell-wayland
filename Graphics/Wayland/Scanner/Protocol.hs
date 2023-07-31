module Graphics.Wayland.Scanner.Protocol (
  readProtocol,
  parseFile,
) where

import Data.Maybe
import Data.Text.IO qualified as T
import Language.Haskell.TH (mkName)
import System.Process
import Text.XML.Light

import Control.Monad
import Graphics.Wayland.Scanner.Names
import Graphics.Wayland.Scanner.Types
import System.FilePath

-- ? Move away from xml, which is quite an outdated package.

protocol = QName "protocol" Nothing Nothing
interface = QName "interface" Nothing Nothing
request = QName "request" Nothing Nothing
event = QName "event" Nothing Nothing
enum = QName "enum" Nothing Nothing
entry = QName "entry" Nothing Nothing
arg = QName "arg" Nothing Nothing
xmlName = QName "name" Nothing Nothing
version = QName "version" Nothing Nothing
allowNull = QName "allow-null" Nothing Nothing
xmlType = QName "type" Nothing Nothing
value = QName "value" Nothing Nothing

-- | Parses interface from XML.
parseInterface :: ProtocolName -> Element -> Interface
parseInterface pname elt =
  let Just iname = findAttr xmlName elt

      parseMessage :: Element -> Maybe Message
      parseMessage msgelt = do
        -- we're gonna do some fancy construction to skip messages we can't deal with yet
        let name = fromJust $ findAttr xmlName msgelt
        arguments <- traverse parseArgument (findChildren arg msgelt)
        let destructorVal = findAttr xmlType msgelt
        let isDestructor = case destructorVal of
              Nothing -> False
              Just str -> str == "destructor"

        pure Message{messageName = name, messageArguments = arguments, messageIsDestructor = isDestructor}
       where
        parseArgument argelt = do
          let msgname = fromJust $ findAttr xmlName argelt
          let argtypecode = fromJust $ findAttr xmlType argelt
          argtype <- case argtypecode of
            "object" -> ObjectArg . mkName . interfaceTypeName pname <$> findAttr interface argelt
            "new_id" -> (\iname -> NewIdArg (mkName $ interfaceTypeName pname iname) iname) <$> findAttr interface argelt
            _ -> lookup argtypecode argConversionTable
          let allow_null = maybe False (read . capitalize) (findAttr allowNull argelt)
          return (msgname, argtype, allow_null)

      parseEnum enumelt =
        let Just enumName = findAttr xmlName enumelt
            enumEntries = map parseEntry $ findChildren entry enumelt
         in WLEnum{enumName, enumEntries}
       where
        parseEntry entryelt =
          ( fromJust $ findAttr xmlName entryelt,
            read $ fromJust $ findAttr value entryelt :: Int
          )
   in Interface
        { interfaceName = iname,
          interfaceVersion = read $ fromJust $ findAttr version elt, -- unused atm
          interfaceRequests = mapMaybe parseMessage (findChildren request elt),
          interfaceEvents = mapMaybe parseMessage (findChildren event elt),
          interfaceEnums = map parseEnum $ findChildren enum elt
        }

parseProtocol :: [Content] -> ProtocolSpec
parseProtocol xmlTree = ProtocolSpec protocolName interfaces
 where
  -- Assumes exactly 1 protocol.
  [theProtocol] = do
    elem <- onlyElems xmlTree
    guard $ elem.elName == protocol
    pure elem
  Just protocolName = findAttr xmlName theProtocol
  interfaces = parseInterface protocolName <$> findChildren interface theProtocol

parseFile :: FilePath -> IO ProtocolSpec
parseFile filename = do
  fileContents <- T.readFile filename
  pure $ parseProtocol (parseXML fileContents)

-- | locate wayland.xml on disk and parse it
readProtocol :: IO ProtocolSpec
readProtocol = do
  datadir <- figureOutWaylandDataDir
  parseFile (datadir </> protocolFile)

-- TODO move this into some pretty Setup.hs thing as soon as someone complains about portability
figureOutWaylandDataDir :: IO FilePath
figureOutWaylandDataDir = do
  output <- readProcess "pkg-config" ["wayland-server", "--variable=pkgdatadir"] []
  pure (head $ lines output)

protocolFile = "wayland.xml"
