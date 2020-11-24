module Tasks.Utils exposing (..)

import Dict
import Process
import Task
import Tasks.Types exposing (..)


projectToString : Model -> Project -> String
projectToString model project =
    let
        maybeClient =
            findClient model project.client_id

        clientName =
            maybeClient |> Maybe.map .name |> Maybe.withDefault ""
    in
    project.name ++ "#" ++ clientName


findClient : Model -> Int -> Maybe Client
findClient model clientId =
    List.filter (\c -> c.id == clientId) model.clients
        |> List.head


isProjectExpanded : Project -> ExpandedProjects -> Bool
isProjectExpanded project expandedProjects =
    case Dict.get (String.fromInt project.id) expandedProjects of
        Just value ->
            value

        Nothing ->
            False


initVisibleProjects : Model -> Model
initVisibleProjects model =
    { model | visibleProjects = buildVisibleProjects model }


nofHiddenProjects : Model -> Int
nofHiddenProjects model =
    List.length model.projects - List.length model.visibleProjects


getVisibleProjects : Model -> List Project
getVisibleProjects model =
    List.filter (\p -> List.any (\id -> id == p.id) model.visibleProjects) model.projects


buildVisibleProjects : Model -> List Int
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


addTaskToProject : Model -> Project -> Task -> Model
addTaskToProject model project task =
    modifyProjectById project.id model (\p -> { p | tasks = p.tasks ++ [ task ] })


modifyProjectById : Int -> Model -> (Project -> Project) -> Model
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


removeTask : Task -> Model -> Model
removeTask task model =
    modifyProjectById task.project_id model (removeTaskFromProject task)


removeTaskFromProject : Task -> Project -> Project
removeTaskFromProject task project =
    { project | tasks = List.filter (\t -> t.id /= task.id) project.tasks }


updateTask : Task -> Model -> Model
updateTask task model =
    modifyProjectById task.project_id model (modifyTaskInProject task)


modifyTaskInProject : Task -> Project -> Project
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


sendMsg : Msg -> Cmd Msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


caseProjectsType : ProjectsType -> a -> a -> a
caseProjectsType projectsType onCurrent onArchived =
    case projectsType of
        CurrentProjects ->
            onCurrent

        ArchivedProjects ->
            onArchived


ternary : Bool -> a -> a -> a
ternary condition trueValue falseValue =
    if condition then
        trueValue

    else
        falseValue


focus : String -> Cmd Msg
focus domElementId =
    Task.attempt (\_ -> Focus domElementId) (Process.sleep 200)


allProjectsExpanded : Model -> Bool
allProjectsExpanded model =
    List.all
        (\p ->
            model.expandedProjects
                |> Dict.get (String.fromInt p.id)
                |> Maybe.withDefault False
        )
        model.projects


sumProjectsPrice : Model -> Float
sumProjectsPrice model =
    List.foldl (\p acc -> acc + sumProjectPrice p) 0 model.projects


sumProjectsPaid : Model -> Float
sumProjectsPaid model =
    List.foldl (\p acc -> acc + p.paid) 0 model.projects


sumProjectPrice : Project -> Float
sumProjectPrice project =
    if project.price > 0 then
        project.price

    else
        project.tasks |> List.foldl (\t acc -> acc + t.price) 0


sumFinishedTasks : List Task -> Float
sumFinishedTasks tasks =
    tasks
        |> List.foldl
            (\t acc ->
                let
                    price =
                        if t.status == "received" || t.status == "sent" then
                            t.price

                        else
                            0
                in
                acc + price
            )
            0


sumAllFinished : Model -> Float
sumAllFinished model =
    model.projects |> List.foldl (\p acc -> acc + sumFinishedTasks p.tasks) 0


splitStringEvery : Int -> String -> String -> String
splitStringEvery nofChars separator str =
    if String.length str < nofChars then
        str

    else
        splitStringEvery nofChars separator (String.dropRight nofChars str)
            ++ separator
            ++ String.right nofChars str


addPriceZeros : String -> String
addPriceZeros str =
    if String.length str == 0 then
        "00"

    else if String.length str == 1 then
        str ++ "0"

    else if String.length str == 2 then
        str

    else
        String.left 2 str


formatPrice : Float -> String
formatPrice price =
    let
        split =
            price |> String.fromFloat |> String.split "."

        int =
            split
                |> List.head
                |> Maybe.withDefault "0"

        intSeparated =
            splitStringEvery 3 " " int

        rest =
            split
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault "00"
                |> addPriceZeros
    in
    intSeparated ++ "." ++ rest


sortTasksByName : List Task -> List Task
sortTasksByName tasks =
    tasks |> List.sortBy .name


allTasksFinished : List Task -> Bool
allTasksFinished tasks =
    List.length tasks > 0 && (tasks |> List.all (\t -> t.status == "sent" || t.status == "received"))


allTasksSent tasks =
    List.length tasks > 0 && (tasks |> List.all (\t -> t.status == "sent"))
