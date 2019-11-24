module Utils exposing (..)

import Dict
import Task
import Types as T


isProjectExpanded : T.Project -> T.ExpandedProjects -> Bool
isProjectExpanded project expandedProjects =
    case Dict.get (String.fromInt project.id) expandedProjects of
        Just value ->
            value

        Nothing ->
            False


initVisibleProjects : T.Model -> T.Model
initVisibleProjects model =
    { model | visibleProjects = buildVisibleProjects model.projects model.searchText }


nofHiddenProjects : T.Model -> Int
nofHiddenProjects model =
    List.length model.projects - List.length model.visibleProjects


getVisibleProjects : T.Model -> List T.Project
getVisibleProjects model =
    List.filter (\p -> List.any (\id -> id == p.id) model.visibleProjects) model.projects


buildVisibleProjects : List T.Project -> String -> List Int
buildVisibleProjects projects searchText =
    projects
        |> List.filter
            (\p ->
                (List.length p.tasks
                    == 0
                    && String.length searchText
                    == 0
                )
                    || (p.tasks
                            |> List.any (\t -> String.contains (String.toLower searchText) (String.toLower t.name))
                       )
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
