module Projects exposing (emptyProject, formView, update)

import Clients
import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModalViewUtils
import Requests as R
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
                        , saveErr = Nothing
                    }

                edCli =
                    model.editedClient

                newEdCli =
                    { edCli
                        | data = Clients.emptyClient
                        , state = T.EditedClientSelected
                        , saveErr = Nothing
                        , searchText = ""
                    }
            in
            ( { model
                | modal = T.ModalEditProject project
                , editedProject = newEdProj
                , editedClient = newEdCli
              }
            , Cmd.none
            )

        T.ProjectsSaveRequest ->
            ( { model | mainViewState = T.LoadingState }, R.createOrUpdateProject model.editedProject.data )

        T.ProjectsCreated project ->
            case project of
                Ok p ->
                    ( model |> addNewProject p |> ModalViewUtils.hideModal, Cmd.none )

                Err err ->
                    let
                        e =
                            Debug.log "created" err
                    in
                    ( model |> saveError, Cmd.none )

        T.ProjectsUpdated project ->
            case project of
                Ok p ->
                    ( model
                        |> replaceProjectById p
                        |> stopLoading T.SuccessState
                        |> ModalViewUtils.hideModal
                    , Cmd.none
                    )

                Err err ->
                    let
                        e =
                            Debug.log "updated" err
                    in
                    ( model |> saveError, Cmd.none )

        T.ProjectsOnInputName str ->
            ( model |> updateEditedProjectData (\p -> { p | name = str }), Cmd.none )

        T.ProjectsOnInputIsDeadlineRigid _ ->
            ( model
                |> updateEditedProjectData
                    (\p -> { p | is_deadline_rigid = not p.is_deadline_rigid })
            , Cmd.none
            )

        T.ProjectsOnInputDeadlineString newDeadline ->
            case Dates.stringToTime newDeadline of
                Ok time ->
                    ( model
                        |> updateEditedProjectData (\d -> { d | deadline = time })
                        |> updateEditedProject
                            (\edProj ->
                                { edProj
                                    | deadlineString = newDeadline
                                    , deadlineErr = Nothing
                                    , saveErr = Nothing
                                }
                            )
                    , Cmd.none
                    )

                Err err ->
                    ( model
                        |> updateEditedProject
                            (\edProj ->
                                { edProj
                                    | deadlineErr = Just err
                                    , deadlineString = newDeadline
                                }
                            )
                    , Cmd.none
                    )

        T.ProjectsOnInputInvoiceNumber newInvoiceNumber ->
            ( model |> updateEditedProjectData (\p -> { p | invoice_number = newInvoiceNumber }), Cmd.none )

        T.ProjectsOnInputPrice newPriceString ->
            ( model |> updateEditedProjectData (\p -> { p | price = Maybe.withDefault 0.0 (String.toFloat newPriceString) }), Cmd.none )

        T.ProjectsOnInputPaid newPaidString ->
            ( model |> updateEditedProjectData (\p -> { p | paid = Maybe.withDefault 0.0 (String.toFloat newPaidString) }), Cmd.none )

        T.ProjectsEditClient clientMsg ->
            Clients.update clientMsg model

        T.ProjectsOnClientIdSelected clientId ->
            ( model |> updateEditedProjectData (\p -> { p | client_id = clientId }), Cmd.none )


saveError : T.Model -> T.Model
saveError model =
    model
        |> updateEditedProject (\edProj -> { edProj | saveErr = Just "Zapisywanie zamówienia nie powiodło się" })
        |> stopLoading T.FailureState


stopLoading : T.MainViewState -> T.Model -> T.Model
stopLoading state model =
    { model | mainViewState = state }


replaceProjectById : T.Project -> T.Model -> T.Model
replaceProjectById project model =
    { model
        | projects =
            model.projects
                |> List.map
                    (\p ->
                        if p.id == project.id then
                            project

                        else
                            p
                    )
                |> sortProjects
    }


sortProjects : List T.Project -> List T.Project
sortProjects projects =
    projects
        |> List.sortWith
            (\a b ->
                compare (Time.posixToMillis a.deadline) (Time.posixToMillis b.deadline)
            )


addNewProject : T.Project -> T.Model -> T.Model
addNewProject project model =
    let
        projects =
            (project :: model.projects)
                |> sortProjects
    in
    { model | projects = projects }


updateEditedProject : (T.EditedProject -> T.EditedProject) -> T.Model -> T.Model
updateEditedProject func model =
    { model | editedProject = func model.editedProject }


updateEditedProjectData : (T.Project -> T.Project) -> T.Model -> T.Model
updateEditedProjectData func model =
    model
        |> updateEditedProject
            (\edProj ->
                { edProj
                    | data = func edProj.data
                    , deadlineErr = Nothing
                    , saveErr = Nothing
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
            [ span [] [ text "Sztywny termin" ]
            , input
                [ type_ "checkbox"
                , checked data.is_deadline_rigid
                , onInput T.ProjectsOnInputIsDeadlineRigid
                ]
                []
            ]
        , fieldset []
            [ legend [] [ text "Klient" ]
            , Html.map
                (\msg -> T.ProjectsEditClient msg)
                (Clients.selectOrCreateView
                    model
                    model.editedProject.data.client_id
                    (\clientId -> T.ProjectsAction (T.ProjectsOnClientIdSelected clientId))
                )
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
    , is_archived = False
    , start_at = Time.millisToPosix 0
    }
