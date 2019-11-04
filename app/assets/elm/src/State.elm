module State exposing (init, update)

import Debug exposing (log)
import Dict
import ExpandedProjectsCache
import Requests
import Types as T
import Utils


init : String -> ( T.Model, Cmd T.Msg )
init flags =
    ( { projects = []
      , workers = []
      , statuses = Dict.empty
      , modal = T.ModalHidden
      , modalPromptValue = ""
      , expandedProjects = ExpandedProjectsCache.decodeExpandedProjectsCache flags
      , mainViewState = T.LoadingState
      }
    , Requests.getAllData
    )


update : T.Msg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.AllDataReceived result ->
            case Debug.log "allData" result of
                Ok allData ->
                    ( { model
                        | projects = allData.projects
                        , workers = allData.workers
                        , statuses = allData.statuses
                        , mainViewState = T.SuccessState
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskCreateRequest project ->
            ( { model | mainViewState = T.LoadingState }, Requests.createNewTask project )

        T.TaskCreated project result ->
            case Debug.log "Task" result of
                Ok task ->
                    let
                        newModel =
                            { model | mainViewState = T.SuccessState }

                        newModelWithTask =
                            addTaskToProject newModel project task
                    in
                    ( newModelWithTask, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.ToggleProjectExpand project ->
            let
                expandedProjects =
                    model.expandedProjects

                isExpanded =
                    Utils.isProjectExpanded project expandedProjects

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
            ( { model | mainViewState = T.LoadingState, modal = T.ModalHidden }, Requests.removeTask task )

        T.TaskRemoved task result ->
            case result of
                Ok delSucceed ->
                    if delSucceed then
                        let
                            newModel =
                                { model | mainViewState = T.SuccessState }
                        in
                        ( removeTask task newModel, Cmd.none )

                    else
                        ( { model | mainViewState = T.FailureState }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskSetWorkerRequest task workerId ->
            ( { model | mainViewState = T.LoadingState }, Requests.changeTaskWorker task workerId )

        T.TaskUpdated result ->
            case result of
                Ok task ->
                    let
                        newModel =
                            updateTask model task
                    in
                    ( { newModel | mainViewState = T.SuccessState }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskRenameModalShow task ->
            ( { model
                | modal = T.ModalPrompt "Nazwa zadania" (T.TaskRenameRequest task)
                , modalPromptValue = task.name
              }
            , Cmd.none
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
            , Requests.renameTask task taskName
            )

        T.TaskChangeStatusRequest task state ->
            ( { model | mainViewState = T.LoadingState }, Requests.changeTaskStatus task state )

        T.ModalClose ->
            ( { model | modal = T.ModalHidden, modalPromptValue = "" }, Cmd.none )

        T.ModalUpdatePromptValue value ->
            ( { model | modalPromptValue = value }, Cmd.none )


addTaskToProject : T.Model -> T.Project -> T.Task -> T.Model
addTaskToProject model project task =
    modifyProjectById project.id model (\p -> { p | tasks = p.tasks ++ [ task ] })


modifyProjectById : Int -> T.Model -> (T.Project -> T.Project) -> T.Model
modifyProjectById projectId model func =
    { model
        | projects =
            List.map
                (\p ->
                    if p.id == projectId then
                        func p

                    else
                        p
                )
                model.projects
    }


removeTask : T.Task -> T.Model -> T.Model
removeTask task model =
    modifyProjectById task.project_id model (removeTaskFromProject task)


removeTaskFromProject : T.Task -> T.Project -> T.Project
removeTaskFromProject task project =
    { project | tasks = List.filter (\t -> t.id /= task.id) project.tasks }


updateTask : T.Model -> T.Task -> T.Model
updateTask model task =
    modifyProjectById task.project_id model (modifyTaskInProject task)


modifyTaskInProject : T.Task -> T.Project -> T.Project
modifyTaskInProject task project =
    { project
        | tasks =
            List.map
                (\t ->
                    if t.id == task.id then
                        task

                    else
                        t
                )
                project.tasks
    }
