module Tasks.View exposing (..)

import Ant.Icons as Icons
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Tasks.Model as M


layout : M.Model -> Element M.Msg
layout model =
    case model.mainViewState of
        M.LoadingState ->
            el [] (text "ładowanie...")

        M.FailureState ->
            el [] (text "wystąpił błąd (sprawdź połączenie)")

        M.SuccessState ->
            column [ width fill ]
                [ toolBar model
                ]


toolBar model =
    column [ width fill ]
        [ row [ width fill ]
            [ expandAll model
            , searchBox model
            , pricesMini "Suma kwot za wszystkie zlecenia"
                { paid = M.sumProjectsPaid model
                , finished = M.sumAllFinished model
                , total = M.sumProjectsPrice model
                }
            ]
        , row [ width fill ]
            [ button
                { label = "dodaj zamówienie"
                , onPress = M.ProjectsMsg M.NewProject
                , icon = Icons.plusCircleOutlined
                }
            ]
        ]


button cfg =
    Input.button
        [ Border.color (rgb255 0 105 217)
        , Border.width 1
        , Border.rounded 4
        , paddingXY 10 2
        , Font.bold
        , Font.color (rgb255 0 105 217)
        , Font.size 12
        , Font.letterSpacing 1
        , mouseOver
            [ Border.color (rgb255 100 100 100)
            , Font.color (rgb255 100 100 100)
            ]
        ]
        { onPress = Just cfg.onPress
        , label = row [ spacing 4 ] [ cfg.icon [], text (String.toUpper cfg.label) ]
        }


searchBox model =
    el [] (text "search")


expandAll model =
    el [] (text "rozwiń")


pricesMini : String -> { paid : Float, finished : Float, total : Float } -> Element M.Msg
pricesMini header prices =
    el [] (text "ceny")
