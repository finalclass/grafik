module View exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Types exposing (..)


layout : Model -> Element Msg
layout model =
    let
        linkColorAttr =
            Font.color (rgb255 0 105 217)
    in
    column [ width fill ]
        [ row [ Background.tiledX "/images/header.jpg", width fill, height (px 57) ]
            [ row [ width (px 1120), centerX ]
                [ link
                    [ Font.color (rgb255 221 27 22), Font.heavy, Font.italic ]
                    { url = "/", label = text "Grafik" }
                , row [ spacing 16, alignRight ]
                    [ link [ linkColorAttr ] { url = "/", label = text "Zamówienia" }
                    , link [ linkColorAttr ] { url = "/workers", label = text "Pracownicy" }
                    ]
                ]
            ]
        , case model.route of
            TasksRoute ->
                el [] (text "Tasks")

            WorkersRoute ->
                el [] (text "Workers")

            NotFoundRoute ->
                el [] (text "Not found")
        ]
