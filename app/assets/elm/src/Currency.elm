module Currency exposing (format)


format : Float -> String
format price =
    let
        split =
            price |> String.fromFloat |> String.split "."

        int =
            split
                |> List.head
                |> Maybe.withDefault "0"

        intSeparated =
            splitStringEvery 3 " " int

        rest =
            split
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault "00"
                |> addZeros
    in
    intSeparated ++ "." ++ rest


splitStringEvery : Int -> String -> String -> String
splitStringEvery nofChars separator str =
    if String.length str < nofChars then
        str

    else
        splitStringEvery nofChars separator (String.dropRight nofChars str)
            ++ separator
            ++ String.right nofChars str


addZeros : String -> String
addZeros str =
    if String.length str == 0 then
        "00"

    else if String.length str == 1 then
        str ++ "0"

    else if String.length str == 2 then
        str

    else
        String.left 2 str
