module State exposing (init, update)

import Browser.Dom
import Clients
import Dates
import Dict
import ExpandedProjectsCache
import Projects
import Requests as R
import Task
import Time
import Types as T
import Utils as U


init : String -> ( T.Model, Cmd T.Msg )
init flags =
    ( { projectsType = T.CurrentProjects
      , projects = []
      , workers = []
      , statuses = []
      , clients = []
      , zone = Time.utc
      , timeNow = Time.millisToPosix 0
      , modal = T.ModalHidden
      , modalPromptValue = ""
      , expandedProjects = ExpandedProjectsCache.decodeExpandedProjectsCache flags
      , mainViewState = T.LoadingState
      , searchText = ""
      , visibleProjects = []
      , editedProject =
            { data = Projects.emptyProject (Time.millisToPosix 0)
            , deadlineString = ""
            , deadlineErr = Nothing
            , startAtErr = Nothing
            , startAtString = ""
            , saveErr = Nothing
            , importedProject = Nothing
            }
      , editedClient =
            { data = Clients.emptyClient
            , state = T.EditedClientSelect
            , saveErr = Nothing
            , searchText = ""
            }
      }
    , R.getAllData T.CurrentProjects
    )


update : T.Msg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.AllDataReceived projectsType result ->
            case result of
                Ok allData ->
                    let
                        newModel =
                            { model
                                | projectsType = projectsType
                                , projects = allData.projects
                                , workers = allData.workers
                                , statuses = allData.statuses
                                , clients = allData.clients
                                , mainViewState = T.SuccessState
                            }
                    in
                    ( { newModel | visibleProjects = U.buildVisibleProjects newModel }
                    , Task.perform T.GotZone Time.here
                    )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.GotZone zone ->
            ( { model | zone = zone }, Task.perform T.GotTime Time.now )

        T.GotTime time ->
            ( { model | timeNow = time }, Cmd.none )

        T.ToggleProjectsType ->
            ( { model | mainViewState = T.LoadingState }
            , R.getAllData (U.caseProjectsType model.projectsType T.ArchivedProjects T.CurrentProjects)
            )

        T.TaskCreateRequest project ->
            ( { model
                | modal = T.ModalPrompt "Nazwa zadania" (T.TaskCreateSave project)
                , modalPromptValue = ""
              }
            , U.focus "modal-prompt-input"
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
                            U.addTaskToProject newModel project task
                    in
                    ( newModelWithTask, Cmd.none )

                Err err ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.ToggleProjectExpand project ->
            let
                expandedProjects =
                    model.expandedProjects

                isExpanded =
                    U.isProjectExpanded project expandedProjects

                newExpandedProjects =
                    Dict.insert (String.fromInt project.id) (not isExpanded) expandedProjects
            in
            ( { model | expandedProjects = newExpandedProjects }
            , ExpandedProjectsCache.addToCache newExpandedProjects
            )

        T.ToggleExpandAllProjects ->
            let
                allExpanded =
                    U.allProjectsExpanded model

                newExpandedProjects =
                    List.foldl
                        (\p acc ->
                            Dict.insert (String.fromInt p.id) (not allExpanded) acc
                        )
                        model.expandedProjects
                        model.projects
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
                        ( U.removeTask task newModel, Cmd.none )

                    else
                        ( { model | mainViewState = T.FailureState }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskSetWorkerRequest task workerId ->
            ( { model | mainViewState = T.LoadingState }, R.changeTaskWorker task workerId )

        T.TaskUpdated result ->
            case result of
                Ok task ->
                    ( { model | mainViewState = T.SuccessState }
                        |> U.updateTask task
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | mainViewState = T.FailureState }, Cmd.none )

        T.TaskRenameModalShow task ->
            ( { model
                | modal = T.ModalPrompt "Nazwa zadania" (T.TaskRenameRequest task)
                , modalPromptValue = task.name
              }
            , U.focus "modal-prompt-input"
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

        T.TaskChangeStatusRequest task status ->
            if status == "sent" then
                let
                    previousStatus =
                        task.status

                    newTask =
                        { task | status = "sent" }
                in
                ( { model
                    | modalPromptValue =
                        if String.length newTask.sent_note > 0 then
                            newTask.sent_note

                        else
                            "Nadano dnia " ++ Dates.displayDate model model.timeNow
                    , modal = T.ModalPrompt "Notka z nadania paczki" (T.TaskSetSentNote task)
                  }
                    |> U.updateTask newTask
                , -- there is some nasty bug in elm that's why we have to do that:
                  U.sendMsg (T.TaskFixStatus previousStatus task)
                )

            else
                ( { model | mainViewState = T.LoadingState }, R.changeTaskStatus task status Nothing )

        T.TaskFixStatus status task ->
            let
                newTask =
                    { task | status = status }
            in
            ( model |> U.updateTask newTask, U.focus "modal-prompt-input" )

        T.TaskSetSentNote task ->
            let
                modalPromptValue =
                    model.modalPromptValue
            in
            ( { model
                | mainViewState = T.LoadingState
                , modal = T.ModalHidden
                , modalPromptValue = ""
              }
            , R.changeTaskStatus task "sent" (Just modalPromptValue)
            )

        T.ModalClose ->
            ( { model | modal = T.ModalHidden, modalPromptValue = "" }, Cmd.none )

        T.ModalUpdatePromptValue value ->
            ( { model | modalPromptValue = value }, Cmd.none )

        T.SearchEnterText value ->
            ( { model | searchText = value } |> U.initVisibleProjects, Cmd.none )

        T.ProjectsAction subMsg ->
            Projects.update subMsg model

        T.Focus id ->
            ( model, Task.attempt (\_ -> T.NoOp) (Browser.Dom.focus id) )

        T.NoOp ->
            ( model, Cmd.none )
