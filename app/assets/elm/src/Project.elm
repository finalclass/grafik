module Project exposing (Project, decoder, price, sumFinished, sumPaid, sumPrice)

import Dates
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import ProjectTask exposing (ProjectTask)
import Time


type alias Project =
    { id : Int
    , client_id : Int
    , name : String
    , description : String
    , is_deadline_rigid : Bool
    , deadline : Time.Posix
    , invoice_number : String
    , price : Float
    , paid : Float
    , tasks : List ProjectTask
    , is_archived : Bool
    , start_at : Time.Posix
    }


sumPrice : List Project -> Float
sumPrice projects =
    List.foldl (\p acc -> acc + price p) 0 projects


sumPaid : List Project -> Float
sumPaid projects =
    List.foldl (\p acc -> acc + p.paid) 0 projects


sumFinished : List Project -> Float
sumFinished projects =
    projects |> List.foldl (\p acc -> acc + ProjectTask.sumFinished p.tasks) 0


price : Project -> Float
price project =
    if project.price > 0 then
        project.price

    else
        project.tasks |> List.foldl (\t acc -> acc + t.price) 0


decoder : D.Decoder Project
decoder =
    D.succeed Project
        |> required "id" D.int
        |> required "client_id" D.int
        |> required "name" D.string
        |> required "description" D.string
        |> required "is_deadline_rigid" D.bool
        |> required "deadline" Dates.decode
        |> optional "invoice_number" D.string ""
        |> optional "price" D.float 0
        |> optional "paid" D.float 0
        |> required "tasks" (D.list ProjectTask.decoder)
        |> required "is_archived" D.bool
        |> required "start_at" Dates.decode
