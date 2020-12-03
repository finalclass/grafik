module Session exposing (Session, init)

import Browser.Navigation as Nav


type alias Session =
    { navKey : Nav.Key
    }


init : Nav.Key -> Session
init navKey =
    { navKey = navKey }
