module Session exposing (Session, init)

import Browser.Navigation as Nav
import Time


type alias Session =
    { navKey : Nav.Key
    , zone : Time.Zone
    , timeNow : Time.Posix
    }


init : Nav.Key -> Time.Zone -> Time.Posix -> Session
init navKey zone time =
    { navKey = navKey
    , zone = zone
    , timeNow = time
    }
