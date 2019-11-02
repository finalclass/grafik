module State exposing (init, update)

import Debug exposing (log)
import Dict
import ExpandedProjectsCache
import Requests
import Types
import Utils


init : String -> ( Types.Model, Cmd Types.Msg )
init flags =
    ( Types.Loading
    , Requests.getAllProjects
        { projects = []
        , expandedProjects = ExpandedProjectsCache.decodeExpandedProjectsCache flags
        }
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.GotProjects modelValue result ->
            case Debug.log "projects" result of
                Ok projects ->
                    ( Types.Success { modelValue | projects = projects }, Cmd.none )

                Err _ ->
                    ( Types.Failure, Cmd.none )

        Types.CreatedTask modelValue project result ->
            case Debug.log "Task" result of
                Ok task ->
                    ( Types.Success (addTaskToProject modelValue project task), Cmd.none )

                Err _ ->
                    ( Types.Failure, Cmd.none )

        Types.CreateNewTask project ->
            case model of
                Types.Success modelValue ->
                    ( Types.Success modelValue, Requests.createNewTask modelValue project )

                model2 ->
                    ( model2, Cmd.none )

        Types.ToggleProjectExpand project ->
            case model of
                Types.Success successModel ->
                    let
                        expandedProjects =
                            successModel.expandedProjects

                        isExpanded =
                            Utils.isProjectExpanded project expandedProjects

                        newExpandedProjects =
                            Dict.insert (String.fromInt project.id) (not isExpanded) expandedProjects
                    in
                    ( Types.Success { successModel | expandedProjects = newExpandedProjects }
                    , ExpandedProjectsCache.addToCache newExpandedProjects
                    )

                model2 ->
                    ( model2, Cmd.none )


addTaskToProject : Types.ModelValue -> Types.Project -> Types.Task -> Types.ModelValue
addTaskToProject modelValue project task =
    { modelValue | projects = List.map (addTaskIfMatch project task) modelValue.projects }


addTaskIfMatch : Types.Project -> Types.Task -> Types.Project -> Types.Project
addTaskIfMatch p1 task p2 =
    if p1.id == p2.id then
        { p1 | tasks = p1.tasks ++ [ task ] }

    else
        p2
