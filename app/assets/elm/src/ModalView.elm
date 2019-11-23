module ModalView exposing (modalView)

import Html exposing (Html, button, div, h3, input, text)
import Html.Attributes exposing (class, id, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Projects
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

        T.ModalEditProject ->
            editProjectView model


editProjectView : T.Model -> Html T.Msg
editProjectView model =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h3 [] [ text model.editedProject.data.name ]
                ]
            , div [ class "modal-body" ]
                [ Html.map (\msg -> T.ProjectsAction msg) (Projects.formView model) ]
            , div [ class "modal-footer" ]
                [ div [ class "project-save-errors float-left" ]
                    [ if model.editedProject.data.client_id == 0 then
                        text "Nie wybrano klienta. "

                      else
                        text ""
                    , if String.length model.editedProject.data.name == 0 then
                        text "Nazwa nie może być pusta"

                      else
                        text ""
                    ]
                , button
                    [ class "float-right"
                    , onClick
                        (if not (projectIsValid model.editedProject.data) then
                            T.NoOp

                         else
                            T.ProjectsAction T.ProjectsSaveRequest
                        )
                    ]
                    [ text "OK" ]
                , button [ class "float-right button-outline", onClick T.ModalClose ]
                    [ text "Anuluj" ]
                ]
            ]
        , div [ class "modal-overlay" ] []
        ]


projectIsValid : T.Project -> Bool
projectIsValid project =
    String.length project.name > 0 && project.client_id > 0


commonModal : String -> List (Html T.Msg) -> List (Html T.Msg) -> Html T.Msg
commonModal headerText body footer =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h3 [] [ text headerText ]
                ]
            , div [ class "modal-body" ]
                body
            , div [ class "modal-footer" ]
                footer
            ]
        , div [ class "modal-overlay" ] []
        ]


okCancelModal : String -> T.Msg -> List (Html T.Msg) -> Html T.Msg
okCancelModal headerText msg body =
    commonModal headerText
        body
        [ button [ class "float-right", onClick msg ]
            [ text "OK" ]
        , button [ class "float-right button-outline", onClick T.ModalClose ]
            [ text "Anuluj" ]
        ]


promptModalView : T.Model -> String -> T.Msg -> Html T.Msg
promptModalView model headerText msg =
    okCancelModal headerText
        msg
        [ input
            [ type_ "text"
            , id "modal-prompt-input"
            , onInput T.ModalUpdatePromptValue
            , onEnter msg
            , value model.modalPromptValue
            ]
            []
        ]


confirmModalView : String -> String -> T.Msg -> Html T.Msg
confirmModalView headerText body msg =
    okCancelModal headerText msg [ text body ]
