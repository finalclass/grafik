module Tasks.Requests exposing (..)

import Http
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Tasks.Types exposing (..)
import Time
import Url


getCurrentProjects : Cmd Msg
getCurrentProjects =
    Http.get
        { url = "/api/all"
        , expect = Http.expectJson CurrentProjectsReceived projectsDecoder
        }


projectsDecoder : D.Decoder AllData
projectsDecoder =
    D.map4 AllData
        (D.field "projects"
            (D.list projectDecoder)
        )
        (D.field "workers"
            (D.list
                (D.map2 Worker
                    (D.field "id" D.int)
                    (D.field "name" D.string)
                )
            )
        )
        (D.field "statuses"
            (D.list
                (D.map2 Status
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


decodeTime : D.Decoder Time.Posix
decodeTime =
    D.int
        |> D.andThen
            (\ms ->
                D.succeed <| Time.millisToPosix ms
            )


projectDecoder : D.Decoder Project
projectDecoder =
    D.succeed Project
        |> required "id" D.int
        |> required "client_id" D.int
        |> required "name" D.string
        |> required "description" D.string
        |> required "is_deadline_rigid" D.bool
        |> required "deadline" decodeTime
        |> optional "invoice_number" D.string ""
        |> optional "price" D.float 0
        |> optional "paid" D.float 0
        |> required "tasks" (D.list taskDecoder)
        |> required "is_archived" D.bool
        |> required "start_at" decodeTime


taskDecoder : D.Decoder Task
taskDecoder =
    D.map7 Task
        (D.field "id" D.int)
        (D.field "project_id" D.int)
        (D.field "worker_id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "sent_note" D.string)
        (D.field "price" D.float)


clientDecoder : D.Decoder Client
clientDecoder =
    D.succeed Client
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
