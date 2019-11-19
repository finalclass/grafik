module Dates exposing (displayDate, stringToTime)

import Array
import DateTime
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


boolToMaybe : Bool -> a -> Maybe a
boolToMaybe bool value =
    if bool then
        Just value

    else
        Nothing


intToMonth : Int -> Time.Month
intToMonth int =
    if int == 1 then
        Time.Jan

    else if int == 2 then
        Time.Feb

    else if int == 3 then
        Time.Mar

    else if int == 4 then
        Time.Apr

    else if int == 5 then
        Time.May

    else if int == 6 then
        Time.Jun

    else if int == 7 then
        Time.Jul

    else if int == 8 then
        Time.Aug

    else if int == 9 then
        Time.Sep

    else if int == 10 then
        Time.Oct

    else if int == 11 then
        Time.Nov

    else
        Time.Dec


isInRange : Int -> Int -> Int -> Maybe Int
isInRange min max number =
    boolToMaybe (number >= min && number <= max) number


stringToTime : String -> Result String Time.Posix
stringToTime string =
    let
        split =
            Array.fromList (String.split "-" string)

        maybeDay =
            Array.get 0 split
                |> Maybe.andThen (\s -> String.toInt s)
                |> Maybe.andThen (\int -> isInRange 1 31 int)

        maybeMonth =
            Array.get 1 split
                |> Maybe.andThen (\s -> String.toInt s)
                |> Maybe.andThen (\int -> isInRange 1 12 int)

        maybeYear =
            Array.get 2 split
                |> Maybe.andThen (\s -> String.toInt s)
                |> Maybe.andThen (\int -> isInRange 1970 3000 int)

        maybePosix =
            Maybe.map4
                (\_ day month year ->
                    { day = day, month = intToMonth month, year = year }
                )
                (boolToMaybe (Array.length split == 3) True)
                maybeDay
                maybeMonth
                maybeYear
                |> Maybe.andThen
                    (\cal ->
                        DateTime.fromRawParts
                            cal
                            { hours = 0
                            , minutes = 0
                            , seconds = 0
                            , milliseconds = 0
                            }
                    )
                |> Maybe.map (\dateTime -> DateTime.toPosix dateTime)
    in
    Result.fromMaybe "Błędny format daty. Poprawnie: DD-MM-YYYY" maybePosix
