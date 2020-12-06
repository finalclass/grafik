module Session exposing (Model, empty, init)

import Browser.Navigation as Nav
import Time


type alias Model =
    { navKey : Nav.Key
    , zone : Time.Zone
    , timeNow : Time.Posix
    }


empty : Nav.Key -> Model
empty navKey =
    { navKey = navKey
    , zone = Time.utc
    , timeNow = Time.millisToPosix 0
    }


init : Nav.Key -> Time.Zone -> Time.Posix -> Model
init navKey zone time =
    { navKey = navKey
    , zone = zone
    , timeNow = time
    }
