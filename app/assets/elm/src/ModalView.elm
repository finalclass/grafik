module ModalView exposing (modalView)

import Html exposing (Html, button, div, form, h3, input, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Types as T


modalView : T.Model -> Html T.Msg
modalView model =
    case model.modal of
        T.ModalHidden ->
            text ""

        T.ModalConfirm header body msg ->
            confirmModalView header body msg

        T.ModalPrompt header buildMsg ->
            promptModalView model header buildMsg


promptModalView : T.Model -> String -> T.Msg -> Html T.Msg
promptModalView model header msg =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h3 [] [ text header ]
                ]
            , div [ class "modal-body" ]
                [ input [ type_ "text", onInput T.ModalUpdatePromptValue, value model.modalPromptValue ] []
                ]
            , div [ class "modal-footer" ]
                [ button [ class "float-right", onClick msg ]
                    [ text "OK" ]
                , button [ class "float-right button-outline", onClick T.ModalClose ]
                    [ text "Anuluj" ]
                ]
            ]
        , div [ class "modal-overlay" ] []
        ]


confirmModalView : String -> String -> T.Msg -> Html T.Msg
confirmModalView header body msg =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h3 [] [ text header ]
                ]
            , div [ class "modal-body" ]
                [ text body ]
            , div [ class "modal-footer" ]
                [ button [ class "float-right", onClick msg ]
                    [ text "OK" ]
                , button [ class "float-right button-outline", onClick T.ModalClose ]
                    [ text "Anuluj" ]
                ]
            ]
        , div [ class "modal-overlay" ] []
        ]
