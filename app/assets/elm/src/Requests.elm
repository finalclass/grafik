module Requests exposing (createNewTask, getAllProjects, removeTask)

import Http
import Json.Decode as D
import Types as T


getAllProjects : Cmd T.Msg
getAllProjects =
    Http.get
        { url = "/api/projects"
        , expect = Http.expectJson T.GotProjects projectsDecoder
        }


removeTask : T.Task -> Cmd T.Msg
removeTask task =
    Http.request
        { method = "DELETE"
        , url = "/api/projects/" ++ String.fromInt task.project_id ++ "/tasks/" ++ String.fromInt task.id
        , body = Http.emptyBody
        , headers = []
        , expect = Http.expectJson (T.TaskRemoved task) taskRemoveDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


createNewTask : T.Project -> Cmd T.Msg
createNewTask project =
    Http.post
        { url = "/api/projects/" ++ String.fromInt project.id ++ "/tasks"
        , body = Http.emptyBody
        , expect = Http.expectJson (T.TaskCreated project) taskDecoder
        }


taskDecoder : D.Decoder T.Task
taskDecoder =
    D.map5 T.Task
        (D.field "id" D.int)
        (D.field "project_id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "worker"
            (D.nullable
                (D.map2 T.Worker
                    (D.field "id" D.int)
                    (D.field "name" D.string)
                )
            )
        )


projectsDecoder : D.Decoder (List T.Project)
projectsDecoder =
    D.field "data"
        (D.list
            (D.map4 T.Project
                (D.field "id" D.int)
                (D.field "name" D.string)
                (D.field "client"
                    (D.map2 T.Client
                        (D.field "id" D.int)
                        (D.field "name" D.string)
                    )
                )
                (D.field "tasks"
                    (D.list taskDecoder)
                )
            )
        )


taskRemoveDecoder : D.Decoder Bool
taskRemoveDecoder =
    D.field "ok" D.bool
