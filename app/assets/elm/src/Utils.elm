module Utils exposing (..)

import Dict
import Process
import Task
import Types as T


projectToString : T.Model -> T.Project -> String
projectToString model project =
    let
        maybeClient =
            findClient model project.client_id

        clientName =
            maybeClient |> Maybe.map .name |> Maybe.withDefault ""
    in
    project.name ++ "#" ++ clientName


findClient : T.Model -> Int -> Maybe T.Client
findClient model clientId =
    List.filter (\c -> c.id == clientId) model.clients
        |> List.head


isProjectExpanded : T.Project -> T.ExpandedProjects -> Bool
isProjectExpanded project expandedProjects =
    case Dict.get (String.fromInt project.id) expandedProjects of
        Just value ->
            value

        Nothing ->
            False


initVisibleProjects : T.Model -> T.Model
initVisibleProjects model =
    { model | visibleProjects = buildVisibleProjects model }


nofHiddenProjects : T.Model -> Int
nofHiddenProjects model =
    List.length model.projects - List.length model.visibleProjects


getVisibleProjects : T.Model -> List T.Project
getVisibleProjects model =
    List.filter (\p -> List.any (\id -> id == p.id) model.visibleProjects) model.projects


buildVisibleProjects : T.Model -> List Int
buildVisibleProjects model =
    let
        hasText =
            \t -> String.contains (String.toLower model.searchText) (String.toLower t)
    in
    model.projects
        |> List.filter
            (\p ->
                (List.length p.tasks
                    == 0
                    && String.length model.searchText
                    == 0
                )
                    || (p.tasks |> List.any (\t -> hasText t.name))
                    || hasText (projectToString model p)
            )
        |> List.map (\p -> p.id)


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


updateTask : T.Task -> T.Model -> T.Model
updateTask task model =
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


hideModal : T.Model -> T.Model
hideModal model =
    { model | modal = T.ModalHidden }


sendMsg : T.Msg -> Cmd T.Msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


caseProjectsType : T.ProjectsType -> a -> a -> a
caseProjectsType projectsType onCurrent onArchived =
    case projectsType of
        T.CurrentProjects ->
            onCurrent

        T.ArchivedProjects ->
            onArchived


ternary : Bool -> a -> a -> a
ternary condition trueValue falseValue =
    if condition then
        trueValue

    else
        falseValue


focus : String -> Cmd T.Msg
focus domElementId =
    Task.attempt (\_ -> T.Focus domElementId) (Process.sleep 200)
