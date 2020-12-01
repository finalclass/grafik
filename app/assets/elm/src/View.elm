module View exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Model as M
import Tasks.View


layout : M.Model -> Element M.Msg
layout model =
    let
        topBarLinkColor =
            Font.color (rgb255 0 105 217)
    in
    column [ width fill ]
        [ row [ Background.tiledX "/images/header.jpg", width fill, height (px 57) ]
            [ row [ width (px 1120), centerX ]
                [ link
                    [ Font.color (rgb255 221 27 22), Font.heavy, Font.italic ]
                    { url = "/", label = text "Grafik" }
                , row [ spacing 16, alignRight ]
                    [ link [ topBarLinkColor ] { url = "/", label = text "Zamówienia" }
                    , link [ topBarLinkColor ] { url = "/workers", label = text "Pracownicy" }
                    ]
                ]
            ]
        , row [ width (px 1120), centerX ]
            [ case model.route of
                M.TasksRoute ->
                    map (\msg -> M.TasksMsg msg) (Tasks.View.layout model.tasks)

                M.WorkersRoute ->
                    el [] (text "Workers")

                M.NotFoundRoute ->
                    el [] (text "Not found")
            ]
        ]
