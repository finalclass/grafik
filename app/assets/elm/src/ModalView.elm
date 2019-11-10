module ModalView exposing (modalView)

import Html exposing (Html, button, div, h3, input, text)
import Html.Attributes exposing (class, id, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Types as T


onEnter : T.Msg -> Html.Attribute T.Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg

            else
                JD.fail "not ENTER"
    in
    on "keydown" (JD.andThen isEnter keyCode)


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
                [ input
                    [ type_ "text"
                    , id "modal-prompt-input"
                    , onInput T.ModalUpdatePromptValue
                    , onEnter msg
                    , value model.modalPromptValue
                    ]
                    []
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
