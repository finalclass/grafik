module Requests exposing (changeTaskStatus, changeTaskWorker, createNewClient, createNewTask, getAllData, removeTask, renameTask)

import Http
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Time
import Types as T


decodeTime : D.Decoder Time.Posix
decodeTime =
    D.int
        |> D.andThen
            (\ms ->
                D.succeed <| Time.millisToPosix ms
            )


getAllData : Cmd T.Msg
getAllData =
    Http.get
        { url = "/api/all"
        , expect = Http.expectJson T.AllDataReceived projectsDecoder
        }


createNewClient : T.Client -> (Int -> T.Msg) -> Cmd T.Msg
createNewClient client makeMsg =
    Http.post
        { url = "/api/clients/"
        , body =
            Http.jsonBody
                (E.object
                    [ ( "name", E.string client.name )
                    , ( "invoice_name", E.string client.invoice_name )
                    , ( "invoice_street", E.string client.invoice_street )
                    , ( "invoice_postcode", E.string client.invoice_postcode )
                    , ( "invoice_city", E.string client.invoice_city )
                    , ( "invoice_nip", E.string client.invoice_nip )
                    , ( "delivery_name", E.string client.delivery_name )
                    , ( "delivery_street", E.string client.delivery_street )
                    , ( "delivery_postcode", E.string client.delivery_postcode )
                    , ( "delivery_city", E.string client.delivery_city )
                    , ( "delivery_contact_person", E.string client.delivery_contact_person )
                    , ( "phone_number", E.string client.phone_number )
                    , ( "email", E.string client.email )
                    ]
                )
        , expect = Http.expectJson (\res -> T.ProjectsAction (T.ProjectsEditClient (T.ClientsCreated makeMsg res))) clientDecoder
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
    D.map6 T.Task
        (D.field "id" D.int)
        (D.field "project_id" D.int)
        (D.field "worker_id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "sent_at" decodeTime)


clientDecoder : D.Decoder T.Client
clientDecoder =
    D.succeed T.Client
        |> required "id" D.int
        |> required "name" D.string
        |> optional "invoice_name" D.string ""
        |> optional "invoice_street" D.string ""
        |> optional "invoice_postcode" D.string ""
        |> optional "invoice_city" D.string ""
        |> optional "invoice_nip" D.string ""
        |> optional "delivery_name" D.string ""
        |> optional "delivery_street" D.string ""
        |> optional "delivery_postcode" D.string ""
        |> optional "delivery_city" D.string ""
        |> optional "delivery_contact_person" D.string ""
        |> optional "phone_number" D.string ""
        |> optional "email" D.string ""


projectsDecoder : D.Decoder T.AllData
projectsDecoder =
    D.map4 T.AllData
        (D.field "projects"
            (D.list
                (D.succeed T.Project
                    |> required "id" D.int
                    |> required "client_id" D.int
                    |> required "name" D.string
                    |> required "is_deadline_rigid" D.bool
                    |> required "deadline" decodeTime
                    |> optional "invoice_number" D.string ""
                    |> optional "price" D.float 0
                    |> optional "paid" D.float 0
                    |> required "tasks" (D.list taskDecoder)
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
        (D.field "clients"
            (D.list
                clientDecoder
            )
        )


taskRemoveDecoder : D.Decoder Bool
taskRemoveDecoder =
    D.field "ok" D.bool
