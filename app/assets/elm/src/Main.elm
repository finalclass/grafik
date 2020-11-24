module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element
import Tasks.State
import Types exposing (..)
import Url
import Url.Parser as UrlParser
import View


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = ClickLink
        , onUrlChange = ChangeUrl
        }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( tasks, cmd ) =
            Tasks.State.init
    in
    ( { navKey = navKey
      , route = urlToRoute url
      , tasks = tasks
      }
    , cmd
    )


routeParser : UrlParser.Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map TasksRoute UrlParser.top
        , UrlParser.map WorkersRoute (UrlParser.s "workers")
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ChangeUrl url ->
            ( { model | route = urlToRoute url }
            , Cmd.none
            )

        TasksMsg subMsg ->
            let
                ( tasks, cmd ) =
                    Tasks.State.update subMsg model.tasks
            in
            ( { model | tasks = tasks }, cmd )


urlToRoute : Url.Url -> Route
urlToRoute url =
    Maybe.withDefault NotFoundRoute (UrlParser.parse routeParser url)


view : Model -> Browser.Document Msg
view model =
    { title = "Grafik"
    , body = [ Element.layout [] (View.layout model) ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
