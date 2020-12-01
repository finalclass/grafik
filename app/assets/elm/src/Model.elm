module Model exposing (..)

import Browser
import Browser.Navigation as Nav
import Tasks.Model
import Url
import Url.Parser as UrlParser


type alias Model =
    { navKey : Nav.Key
    , route : Route
    , tasks : Tasks.Model.Model
    }


type Route
    = TasksRoute
    | WorkersRoute
    | NotFoundRoute


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | TasksMsg Tasks.Model.Msg


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( tasks, cmd ) =
            Tasks.Model.init

        mappedCmd =
            Cmd.map (\tasksMsg -> TasksMsg tasksMsg) cmd
    in
    ( { navKey = navKey
      , route = urlToRoute url
      , tasks = tasks
      }
    , mappedCmd
    )


routeParser : UrlParser.Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map TasksRoute UrlParser.top
        , UrlParser.map WorkersRoute (UrlParser.s "workers")
        ]


urlToRoute : Url.Url -> Route
urlToRoute url =
    Maybe.withDefault NotFoundRoute (UrlParser.parse routeParser url)
