module Requests exposing (createNewTask, getAllData, removeTask)

import Http
import Json.Decode as D
import Types as T


getAllData : Cmd T.Msg
getAllData =
    Http.get
        { url = "/api/all"
        , expect = Http.expectJson T.AllDataReceived projectsDecoder
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


projectsDecoder : D.Decoder T.AllData
projectsDecoder =
    D.map2 T.AllData
        (D.field "projects"
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
        )
        (D.field "workers"
            (D.list
                (D.map2 T.Worker
                    (D.field "id" D.int)
                    (D.field "name" D.string)
                )
            )
        )


taskRemoveDecoder : D.Decoder Bool
taskRemoveDecoder =
    D.field "ok" D.bool
