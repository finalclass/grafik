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
            ( { model
                | modal = T.ModalEditProject project
                , editedProject = project
                , editedProjectDeadlineString = Dates.displayDate model project.deadline
              }
            , Cmd.none
            )

        T.ProjectsSaveRequest project ->
            ( model, Cmd.none )

        T.ProjectsOnInputName str ->
            ( modifyEditedProject model (\p -> { p | name = str }), Cmd.none )

        T.ProjectsOnInputIsDeadlineRigid _ ->
            ( modifyEditedProject model
                (\p -> { p | is_deadline_rigid = not model.editedProject.is_deadline_rigid })
            , Cmd.none
            )

        T.ProjectsOnInputDeadlineString newDeadline ->
            case Dates.stringToTime newDeadline of
                Ok time ->
                    let
                        editedProject =
                            model.editedProject

                        newEditedProject =
                            { editedProject | deadline = time }
                    in
                    ( { model
                        | editedProject = newEditedProject
                        , editedProjectDeadlineString = newDeadline
                        , editedProjectDeadlineError = ""
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model
                        | editedProjectDeadlineError = err
                        , editedProjectDeadlineString = newDeadline
                      }
                    , Cmd.none
                    )

        T.ProjectsOnInputInvoiceNumber newInvoiceNumber ->
            ( modifyEditedProject model (\p -> { p | invoice_number = newInvoiceNumber }), Cmd.none )

        T.ProjectsOnInputPrice newPriceString ->
            ( modifyEditedProject model (\p -> { p | price = Maybe.withDefault 0.0 (String.toFloat newPriceString) }), Cmd.none )

        T.ProjectsOnInputPaid newPaidString ->
            ( modifyEditedProject model (\p -> { p | paid = Maybe.withDefault 0.0 (String.toFloat newPaidString) }), Cmd.none )


modifyEditedProject : T.Model -> (T.Project -> T.Project) -> T.Model
modifyEditedProject model func =
    { model
        | editedProject = func model.editedProject
        , editedProjectDeadlineError = ""
    }


formView : T.Model -> Html T.ProjectsMsg
formView model =
    div []
        [ label []
            [ span [] [ text "Nazwa" ]
            , input
                [ type_ "text"
                , value model.editedProject.name
                , onInput T.ProjectsOnInputName
                ]
                []
            ]
        , label []
            [ span [] [ text "Sztywny termin" ]
            , input
                [ type_ "checkbox"
                , checked model.editedProject.is_deadline_rigid
                , onInput T.ProjectsOnInputIsDeadlineRigid
                ]
                []
            ]
        , label []
            [ span []
                [ text
                    ("Termin"
                        ++ (if String.length model.editedProjectDeadlineError == 0 then
                                " (" ++ Dates.displayDate model model.editedProject.deadline ++ ")"

                            else
                                ""
                           )
                    )
                ]
            , input
                [ type_ "text"
                , value model.editedProjectDeadlineString
                , onInput T.ProjectsOnInputDeadlineString
                ]
                []
            , if String.length model.editedProjectDeadlineError > 0 then
                div [ class "error-message" ] [ text model.editedProjectDeadlineError ]

              else
                text ""
            ]
        , label []
            [ span [] [ text "Numer faktury / oferty" ]
            , input
                [ type_ "text"
                , value model.editedProject.invoice_number
                , onInput T.ProjectsOnInputInvoiceNumber
                ]
                []
            ]
        , label []
            [ span [] [ text "Cena" ]
            , input
                [ type_ "number"
                , step "0.01"
                , value (String.fromFloat model.editedProject.paid)
                , onInput T.ProjectsOnInputPrice
                ]
                []
            ]
        , label []
            [ span [] [ text "Zapłacono" ]
            , input
                [ type_ "number"
                , step "0.01"
                , value (String.fromFloat model.editedProject.paid)
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
