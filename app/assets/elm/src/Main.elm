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
            let
                route =
                    urlToRoute url

                ( newModel, cmd ) =
                    case route of
                        TasksRoute ->
                            let
                                ( tasksModel, tasksCmd ) =
                                    Tasks.State.init
                            in
                            ( { model | tasks = tasksModel }, Cmd.map (\tasksMsg -> TasksMsg tasksMsg) tasksCmd )

                        WorkersRoute ->
                            ( model, Cmd.none )

                        NotFoundRoute ->
                            ( model, Cmd.none )
            in
            ( { newModel | route = route }, cmd )

        TasksMsg subMsg ->
            let
                ( tasksModel, tasksCmd ) =
                    Tasks.State.update subMsg model.tasks
            in
            ( { model | tasks = tasksModel }, Cmd.map (\tasksMsg -> TasksMsg tasksMsg) tasksCmd )


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
