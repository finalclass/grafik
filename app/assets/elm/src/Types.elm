module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Tasks.Types
import Url


type alias Model =
    { navKey : Nav.Key
    , route : Route
    , tasks : Tasks.Types.Model
    }


type Route
    = TasksRoute
    | WorkersRoute
    | NotFoundRoute


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | TasksMsg Tasks.Types.Msg
