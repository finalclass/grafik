module Dates exposing (displayDate)

import Time
import Types as T


toNumericMounth : Time.Month -> Int
toNumericMounth month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


prefixZero : Int -> String
prefixZero num =
    let
        numStr =
            String.fromInt num
    in
    if String.length numStr == 1 then
        "0" ++ numStr

    else
        numStr


displayDate : T.Model -> Time.Posix -> String
displayDate model posixTime =
    prefixZero (Time.toDay model.zone posixTime)
        ++ "-"
        ++ prefixZero (toNumericMounth (Time.toMonth model.zone posixTime))
        ++ "-"
        ++ String.fromInt (Time.toYear model.zone posixTime)
