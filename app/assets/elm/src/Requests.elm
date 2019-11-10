module Requests exposing (changeTaskStatus, changeTaskWorker, createNewTask, getAllData, removeTask, renameTask)

import Http
import Json.Decode as D
import Json.Encode as E
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


createNewTask : T.Project -> String -> Cmd T.Msg
createNewTask project name =
    Http.post
        { url = "/api/projects/" ++ String.fromInt project.id ++ "/tasks"
        , body =
            Http.jsonBody
                (E.object
                    [ ( "name", E.string name )
                    ]
                )
        , expect = Http.expectJson (T.TaskCreated project) taskDecoder
        }


modifyTask : T.Task -> List ( String, E.Value ) -> Cmd T.Msg
modifyTask task fields =
    Http.request
        { method = "PUT"
        , url = "/api/projects/" ++ String.fromInt task.project_id ++ "/tasks/" ++ String.fromInt task.id
        , body =
            Http.jsonBody
                (E.object
                    [ ( "task"
                      , E.object
                            fields
                      )
                    ]
                )
        , headers = []
        , expect = Http.expectJson T.TaskUpdated taskDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


changeTaskStatus : T.Task -> String -> Cmd T.Msg
changeTaskStatus task status =
    modifyTask task [ ( "status", E.string status ) ]


changeTaskWorker : T.Task -> String -> Cmd T.Msg
changeTaskWorker task workerId =
    modifyTask task [ ( "worker_id", E.string workerId ) ]


renameTask : T.Task -> String -> Cmd T.Msg
renameTask task newName =
    modifyTask task [ ( "name", E.string newName ) ]


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
    D.map3 T.AllData
        (D.field "projects"
            (D.list
                (D.map5 T.Project
                    (D.field "id" D.int)
                    (D.field "client_id" D.int)
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
        (D.field "statuses"
            (D.list
                (D.map2 T.Status
                    (D.field "id" D.string)
                    (D.field "name" D.string)
                )
            )
        )


taskRemoveDecoder : D.Decoder Bool
taskRemoveDecoder =
    D.field "ok" D.bool
