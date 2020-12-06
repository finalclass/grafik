module ProjectTask exposing (ProjectTask, decoder, sumFinished)

import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)


type alias ProjectTask =
    { id : Int
    , project_id : Int
    , worker_id : Int
    , name : String
    , status : String
    , sent_note : String
    , price : Float
    }


sumFinished : List ProjectTask -> Float
sumFinished tasks =
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


decoder : D.Decoder ProjectTask
decoder =
    D.map7 ProjectTask
        (D.field "id" D.int)
        (D.field "project_id" D.int)
        (D.field "worker_id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "sent_note" D.string)
        (D.field "price" D.float)
