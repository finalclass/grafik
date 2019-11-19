module Projects exposing (emptyProject, formView, update)

import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types as T


update : T.ProjectsMsg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.ProjectsStartEdit project ->
            let
                edProj =
                    model.editedProject

                newEdProj =
                    { edProj
                        | data = project
                        , deadlineString = Dates.displayDate model project.deadline
                        , deadlineErr = Nothing
                    }
            in
            ( { model | modal = T.ModalEditProject project, editedProject = newEdProj }, Cmd.none )

        T.ProjectsSaveRequest project ->
            ( model, Cmd.none )

        T.ProjectsOnInputName str ->
            ( modifyEditedProjectData model (\p -> { p | name = str }), Cmd.none )

        T.ProjectsOnInputIsDeadlineRigid _ ->
            ( modifyEditedProjectData model
                (\p -> { p | is_deadline_rigid = not p.is_deadline_rigid })
            , Cmd.none
            )

        T.ProjectsOnInputDeadlineString newDeadline ->
            case Dates.stringToTime newDeadline of
                Ok time ->
                    let
                        newModel =
                            modifyEditedProjectData model (\d -> { d | deadline = time })
                    in
                    ( modifyEditedProject newModel
                        (\edProj ->
                            { edProj
                                | deadlineString = newDeadline
                                , deadlineErr = Nothing
                            }
                        )
                    , Cmd.none
                    )

                Err err ->
                    ( modifyEditedProject model
                        (\edProj ->
                            { edProj
                                | deadlineErr = Just err
                                , deadlineString = newDeadline
                            }
                        )
                    , Cmd.none
                    )

        T.ProjectsOnInputInvoiceNumber newInvoiceNumber ->
            ( modifyEditedProjectData model (\p -> { p | invoice_number = newInvoiceNumber }), Cmd.none )

        T.ProjectsOnInputPrice newPriceString ->
            ( modifyEditedProjectData model (\p -> { p | price = Maybe.withDefault 0.0 (String.toFloat newPriceString) }), Cmd.none )

        T.ProjectsOnInputPaid newPaidString ->
            ( modifyEditedProjectData model (\p -> { p | paid = Maybe.withDefault 0.0 (String.toFloat newPaidString) }), Cmd.none )


modifyEditedProject : T.Model -> (T.EditedProject -> T.EditedProject) -> T.Model
modifyEditedProject model func =
    { model | editedProject = func model.editedProject }


modifyEditedProjectData : T.Model -> (T.Project -> T.Project) -> T.Model
modifyEditedProjectData model func =
    modifyEditedProject model
        (\edProj ->
            { edProj
                | data = func edProj.data
                , deadlineErr = Nothing
            }
        )


formView : T.Model -> Html T.ProjectsMsg
formView model =
    let
        data =
            model.editedProject.data
    in
    div []
        [ label []
            [ span [] [ text "Nazwa" ]
            , input
                [ type_ "text"
                , value data.name
                , onInput T.ProjectsOnInputName
                ]
                []
            ]
        , label []
            [ span [] [ text "Sztywny termin" ]
            , input
                [ type_ "checkbox"
                , checked data.is_deadline_rigid
                , onInput T.ProjectsOnInputIsDeadlineRigid
                ]
                []
            ]
        , label []
            [ span []
                [ text "Termin"
                , span
                    [ class
                        (case model.editedProject.deadlineErr of
                            Just _ ->
                                "invalid-date"

                            Nothing ->
                                ""
                        )
                    ]
                    [ text (" (" ++ Dates.displayDate model data.deadline ++ ")")
                    ]
                ]
            , input
                [ type_ "text"
                , value model.editedProject.deadlineString
                , onInput T.ProjectsOnInputDeadlineString
                ]
                []
            , case model.editedProject.deadlineErr of
                Just err ->
                    div [ class "error-message" ] [ text err ]

                Nothing ->
                    text ""
            ]
        , label []
            [ span [] [ text "Numer faktury / oferty" ]
            , input
                [ type_ "text"
                , value data.invoice_number
                , onInput T.ProjectsOnInputInvoiceNumber
                ]
                []
            ]
        , label []
            [ span [] [ text "Cena" ]
            , input
                [ type_ "number"
                , step "0.01"
                , value (String.fromFloat data.price)
                , onInput T.ProjectsOnInputPrice
                ]
                []
            ]
        , label []
            [ span [] [ text "Zapłacono" ]
            , input
                [ type_ "number"
                , step "0.01"
                , value (String.fromFloat data.paid)
                , onInput T.ProjectsOnInputPaid
                ]
                []
            ]
        ]


emptyProject : T.Project
emptyProject =
    { id = 0
    , client_id = 0
    , name = ""
    , is_deadline_rigid = False
    , deadline = Time.millisToPosix 0
    , invoice_number = ""
    , price = 0
    , paid = 0
    , tasks = []
    }
