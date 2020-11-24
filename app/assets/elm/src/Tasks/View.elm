module Tasks.View exposing (..)

import Element exposing (..)
import Tasks.Types exposing (..)


layout : Model -> Element Msg
layout model =
    case model.mainViewState of
        LoadingState ->
            el [] (text "ładowanie...")

        FailureState ->
            el [] (text "wystąpił błąd (sprawdź połączenie)")

        SuccessState ->
            toolBar model


toolBar model =
    el [] (text "TOOLBAR")
