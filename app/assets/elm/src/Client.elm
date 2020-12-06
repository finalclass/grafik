module Client exposing (Client, decoder)

import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)


type alias Client =
    { id : Int
    , name : String
    , invoice_name : String
    , invoice_street : String
    , invoice_postcode : String
    , invoice_city : String
    , invoice_nip : String
    , delivery_name : String
    , delivery_street : String
    , delivery_postcode : String
    , delivery_city : String
    , delivery_contact_person : String
    , phone_number : String
    , email : String
    }


decoder : D.Decoder Client
decoder =
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
