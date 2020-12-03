module Route exposing (Route(..), urlToRoute)

import Url
import Url.Parser as UrlParser


type Route
    = ProjectsRoute
    | WorkersRoute
    | NotFoundRoute


routeParser : UrlParser.Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map ProjectsRoute UrlParser.top
        , UrlParser.map WorkersRoute (UrlParser.s "workers")
        ]


urlToRoute : Url.Url -> Route
urlToRoute url =
    Maybe.withDefault NotFoundRoute (UrlParser.parse routeParser url)