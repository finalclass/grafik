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
      , expandedProjects = ExpandedProjectsCache.decodeExpandedProjectsCache flags
      , mainViewState = T.MainViewShowLoading
      }
    , Requests.getAllProjects
    )


update : T.Msg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.GotProjects result ->
            case Debug.log "projects" result of
                Ok projects ->
                    ( { model
                        | projects = projects
                        , mainViewState = T.MainViewShowProjects
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | mainViewState = T.MainViewShowFailure }, Cmd.none )

        T.TaskCreated project result ->
            case Debug.log "Task" result of
                Ok task ->
                    ( addTaskToProject model project task, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        T.TaskCreateRequest project ->
            ( model, Requests.createNewTask project )

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
            ( model, Requests.removeTask task )

        T.TaskRemoved task result ->
            case result of
                Ok delSucceed ->
                    if delSucceed then
                        ( removeTask task model, Cmd.none )

                    else
                        ( { model | mainViewState = T.MainViewShowFailure }, Cmd.none )

                Err _ ->
                    ( { model | mainViewState = T.MainViewShowFailure }, Cmd.none )


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
