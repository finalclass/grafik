module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Url


type alias Model =
    { navKey : Nav.Key
    , route : Route
    }


type Route
    = TasksRoute
    | WorkersRoute
    | NotFoundRoute


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
