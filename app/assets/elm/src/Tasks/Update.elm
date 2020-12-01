module Tasks.Update exposing (..)

import Browser.Dom
import Dict
import Task
import Tasks.Model as M
import Tasks.Requests as R
import Time


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.NoOp ->
            ( model, Cmd.none )

        M.Init ->
            ( model, R.getCurrentProjects )

        M.CurrentProjectsReceived result ->
            case result of
                Ok allData ->
                    let
                        newModel =
                            { model
                                | projectsType = M.CurrentProjects
                                , projects = allData.projects
                                , workers = allData.workers
                                , statuses = allData.statuses
                                , clients = allData.clients
                                , mainViewState = M.SuccessState
                            }
                    in
                    ( { newModel | visibleProjects = M.buildVisibleProjects newModel }
                    , Task.perform M.GotZone Time.here
                    )

                Err _ ->
                    ( { model | mainViewState = M.FailureState }, Cmd.none )

        M.GotZone zone ->
            ( { model | zone = zone }, Task.perform M.GotTime Time.now )

        M.GotTime time ->
            ( { model | timeNow = time }, Cmd.none )

        M.Focus id ->
            ( model, Task.attempt (\_ -> M.NoOp) (Browser.Dom.focus id) )

        M.ProjectsMsg subMsg ->
            updateProjects subMsg model


updateProjects subMsg model =
    case subMsg of
        M.NewProject ->
            ( model, Cmd.none )
