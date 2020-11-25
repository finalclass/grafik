module Tasks.State exposing (..)

import Browser.Dom
import Dict
import Task
import Tasks.Requests as R
import Tasks.Types exposing (..)
import Tasks.Utils as U
import Time


init =
    ( { mainViewState = LoadingState
      , projectsType = CurrentProjects
      , projects = []
      , workers = []
      , statuses = []
      , clients = []
      , visibleProjects = []
      , zone = Time.utc
      , timeNow = Time.millisToPosix 0
      , searchText = ""
      , expandedProjects = Dict.empty
      }
    , R.getCurrentProjects
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CurrentProjectsReceived result ->
            case result of
                Ok allData ->
                    let
                        newModel =
                            { model
                                | projectsType = CurrentProjects
                                , projects = allData.projects
                                , workers = allData.workers
                                , statuses = allData.statuses
                                , clients = allData.clients
                                , mainViewState = SuccessState
                            }
                    in
                    ( { newModel | visibleProjects = U.buildVisibleProjects newModel }
                    , Task.perform GotZone Time.here
                    )

                Err _ ->
                    ( { model | mainViewState = FailureState }, Cmd.none )

        GotZone zone ->
            ( { model | zone = zone }, Task.perform GotTime Time.now )

        GotTime time ->
            ( { model | timeNow = time }, Cmd.none )

        Focus id ->
            ( model, Task.attempt (\_ -> NoOp) (Browser.Dom.focus id) )

        ProjectsMsg subMsg ->
            updateProjects subMsg model


updateProjects subMsg model =
    case subMsg of
        NewProject ->
            ( model, Cmd.none )
