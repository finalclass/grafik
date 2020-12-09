module Session exposing (Session, empty, init, saveToLocalStorage)

import Browser.Navigation as Nav
import Time


type alias Session =
    { navKey : Nav.Key
    , zone : Time.Zone
    , timeNow : Time.Posix
    }


empty : Nav.Key -> Session
empty navKey =
    { navKey = navKey
    , zone = Time.utc
    , timeNow = Time.millisToPosix 0
    }


init : Nav.Key -> Time.Zone -> Time.Posix -> Session
init navKey zone time =
    { navKey = navKey
    , zone = zone
    , timeNow = time
    }


saveToLocalStorage : Session -> { key : String, value : String } -> Session
saveToLocalStorage session item =
    session
