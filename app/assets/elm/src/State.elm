module State exposing (init, update)

import Browser.Dom
import Debug exposing (log)
import Dict
import ExpandedProjectsCache
import Model as M
import Process
import Projects
import Requests as R
import Task
import Time
import Types as T


init : String -> ( T.Model, Cmd T.Msg )
init flags =
    ( { projects = []
      , workers = []
      , statuses = []
      , clients = []
      , zone = Time.utc
      , modal = T.ModalHidden
      , modalPromptValue = ""
      , expandedProjects = ExpandedProjectsCache.decodeExpandedProjectsCache flags
      , mainViewState = T.LoadingState
      , searchText = ""
      , visibleProjects = []
      , editedProject = Projects.emptyProject
      }
    , R.getAllData
    )


update : T.Msg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.AllDataReceived result ->
            case result of
                Ok allData ->
                    ( { model
                        | projects = allData.projects
                        , workers = allData.workers
                        , statuses = allData.statuses
                        , clients = allData.clients
                        , mainViewState = T.SuccessState
                        , visibleProjects = M.buildVisibleProjects allData.projects ""
                      }
                    , Task.perform T.GotZone Time.here
                    )

                Err err ->
                    let
                        err2 =
                            Debug.log "error" err
                    in
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.GotZone zone1 ->
            ( { model | zone = zone1 }, Cmd.none )

        T.TaskCreateRequest project ->
            ( { model
                | modal = T.ModalPrompt "Nazwa zadania" (T.TaskCreateSave project)
                , modalPromptValue = ""
              }
            , Task.attempt (\_ -> T.Focus "modal-prompt-input") (Process.sleep 200)
            )

        T.TaskCreateSave project ->
            if String.length model.modalPromptValue > 0 then
                ( { model
                    | mainViewState = T.LoadingState
                    , modal = T.ModalHidden
                    , modalPromptValue = ""
                  }
                , R.createNewTask project model.modalPromptValue
                )

            else
                update T.ModalClose model

        T.TaskCreated project result ->
            case result of
                Ok task ->
                    let
                        newModel =
                            { model | mainViewState = T.SuccessState }

                        newModelWithTask =
                            M.addTaskToProject newModel project task
                    in
                    ( newModelWithTask, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.ToggleProjectExpand project ->
            let
                expandedProjects =
                    model.expandedProjects

                isExpanded =
                    M.isProjectExpanded project expandedProjects

                newExpandedProjects =
                    Dict.insert (String.fromInt project.id) (not isExpanded) expandedProjects
            in
            ( { model | expandedProjects = newExpandedProjects }
            , ExpandedProjectsCache.addToCache newExpandedProjects
            )

        T.TaskRemoveRequest task ->
            ( { model | modal = T.ModalConfirm "Potwierdź" "Czy na pewno usunąć?" (T.TaskRemoveConfirmed task) }
            , Cmd.none
            )

        T.TaskRemoveConfirmed task ->
            ( { model | mainViewState = T.LoadingState, modal = T.ModalHidden }, R.removeTask task )

        T.TaskRemoved task result ->
            case result of
                Ok delSucceed ->
                    if delSucceed then
                        let
                            newModel =
                                { model | mainViewState = T.SuccessState }
                        in
                        ( M.removeTask task newModel, Cmd.none )

                    else
                        ( { model | mainViewState = T.FailureState }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskSetWorkerRequest task workerId ->
            ( { model | mainViewState = T.LoadingState }, R.changeTaskWorker task workerId )

        T.TaskUpdated result ->
            case result of
                Ok task ->
                    let
                        newModel =
                            M.updateTask model task
                    in
                    ( { newModel | mainViewState = T.SuccessState }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskRenameModalShow task ->
            ( { model
                | modal = T.ModalPrompt "Nazwa zadania" (T.TaskRenameRequest task)
                , modalPromptValue = task.name
              }
            , Task.attempt (\_ -> T.Focus "modal-prompt-input") (Process.sleep 200)
            )

        T.TaskRenameRequest task ->
            let
                taskName =
                    model.modalPromptValue
            in
            ( { model
                | modalPromptValue = ""
                , modal = T.ModalHidden
                , mainViewState = T.LoadingState
              }
            , R.renameTask task taskName
            )

        T.TaskChangeStatusRequest task state ->
            ( { model | mainViewState = T.LoadingState }, R.changeTaskStatus task state )

        T.ModalClose ->
            ( { model | modal = T.ModalHidden, modalPromptValue = "" }, Cmd.none )

        T.ModalUpdatePromptValue value ->
            ( { model | modalPromptValue = value }, Cmd.none )

        T.SearchEnterText value ->
            ( { model | searchText = value, visibleProjects = M.buildVisibleProjects model.projects value }, Cmd.none )

        T.ProjectsAction subMsg ->
            Projects.update subMsg model

        T.Focus id ->
            ( model, Task.attempt (\_ -> T.NoOp) (Browser.Dom.focus id) )

        T.NoOp ->
            ( model, Cmd.none )
