module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element
import Model as M
import Tasks.Model
import Tasks.Update
import Url
import Url.Parser as UrlParser
import View


main : Program String M.Model M.Msg
main =
    Browser.application
        { init = M.init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = M.ClickLink
        , onUrlChange = M.ChangeUrl
        }


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.ClickLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        M.ChangeUrl url ->
            let
                route =
                    M.urlToRoute url

                ( newModel, cmd ) =
                    case route of
                        M.TasksRoute ->
                            let
                                ( tasksModel, tasksCmd ) =
                                    Tasks.Model.init
                            in
                            ( { model | tasks = tasksModel }, Cmd.map (\tasksMsg -> M.TasksMsg tasksMsg) tasksCmd )

                        M.WorkersRoute ->
                            ( model, Cmd.none )

                        M.NotFoundRoute ->
                            ( model, Cmd.none )
            in
            ( { newModel | route = route }, cmd )

        M.TasksMsg subMsg ->
            let
                ( tasksModel, tasksCmd ) =
                    Tasks.Update.update subMsg model.tasks
            in
            ( { model | tasks = tasksModel }, Cmd.map (\tasksMsg -> M.TasksMsg tasksMsg) tasksCmd )


view : M.Model -> Browser.Document M.Msg
view model =
    { title = "Grafik"
    , body = [ Element.layout [] (View.layout model) ]
    }


subscriptions : M.Model -> Sub M.Msg
subscriptions _ =
    Sub.none
