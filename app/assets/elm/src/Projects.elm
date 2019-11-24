module Projects exposing (editProjectModalView, emptyProject, formView, update)

import Clients
import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Requests as R
import Time
import Types as T
import Utils as U


update : T.ProjectsMsg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.ProjectsStartEdit project ->
            ( model
                |> initEditedProject project
                |> showEditProjectModal
                |> initEditedClient
            , Cmd.none
            )

        T.ProjectsNewProject ->
            ( model
                |> initEditedProject (emptyProject model.timeNow)
                |> showEditProjectModal
                |> initEditedClient
            , Cmd.none
            )

        T.ProjectsSaveRequest ->
            ( { model | mainViewState = T.LoadingState }, R.createOrUpdateProject model.editedProject.data )

        T.ProjectsCreated project ->
            case project of
                Ok p ->
                    let
                        model1 =
                            if
                                (p.is_archived && model.projectsType == T.CurrentProjects)
                                    || (not p.is_archived && model.projectsType == T.ArchivedProjects)
                            then
                                model

                            else
                                model |> addNewProject p
                    in
                    ( { model1 | mainViewState = T.SuccessState }
                        |> U.hideModal
                        |> U.initVisibleProjects
                    , U.sendMsg (T.ToggleProjectExpand p)
                    )

                Err err ->
                    ( model |> saveError, Cmd.none )

        T.ProjectsUpdated project ->
            case project of
                Ok p ->
                    let
                        model1 =
                            if
                                (p.is_archived && model.projectsType == T.CurrentProjects)
                                    || (not p.is_archived && model.projectsType == T.ArchivedProjects)
                            then
                                { model | projects = List.filter (\p2 -> p2.id /= p.id) model.projects }

                            else
                                model
                    in
                    ( model1
                        |> replaceProjectById p
                        |> stopLoading T.SuccessState
                        |> U.hideModal
                        |> U.initVisibleProjects
                    , Cmd.none
                    )

                Err err ->
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

        T.ProjectsOnInputStartAtString newStartAt ->
            case Dates.stringToTime newStartAt of
                Ok time ->
                    ( model
                        |> updateEditedProjectData (\d -> { d | start_at = time })
                        |> updateEditedProject
                            (\edProj ->
                                { edProj
                                    | startAtString = newStartAt
                                    , startAtErr = Nothing
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
                                    | startAtErr = Just err
                                    , startAtString = newStartAt
                                }
                            )
                    , Cmd.none
                    )

        T.ProjectsOnInputPrice newPriceString ->
            ( model |> updateEditedProjectData (\p -> { p | price = Maybe.withDefault 0.0 (String.toFloat newPriceString) }), Cmd.none )

        T.ProjectsOnInputPaid newPaidString ->
            ( model |> updateEditedProjectData (\p -> { p | paid = Maybe.withDefault 0.0 (String.toFloat newPaidString) }), Cmd.none )

        T.ProjectsEditClient clientMsg ->
            Clients.update clientMsg model

        T.ProjectsOnClientIdSelected clientId ->
            ( model |> updateEditedProjectData (\p -> { p | client_id = clientId }), Cmd.none )

        T.ProjectsOnInputIsArchived _ ->
            ( model
                |> updateEditedProjectData
                    (\p -> { p | is_archived = not p.is_archived })
            , Cmd.none
            )


showEditProjectModal : T.Model -> T.Model
showEditProjectModal model =
    { model | modal = T.ModalEditProject }


initEditedProject : T.Project -> T.Model -> T.Model
initEditedProject project model =
    model
        |> updateEditedProject
            (\_ ->
                { data = project
                , deadlineString = Dates.displayDate model project.deadline
                , deadlineErr = Nothing
                , startAtString = Dates.displayDate model project.start_at
                , startAtErr = Nothing
                , saveErr = Nothing
                }
            )


initEditedClient : T.Model -> T.Model
initEditedClient model =
    { model
        | editedClient =
            { data = Clients.emptyClient
            , state = T.EditedClientSelected
            , saveErr = Nothing
            , searchText = ""
            }
    }


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
        , model
            |> Dates.dateInputView
                { label = "Termin"
                , time = data.deadline
                , timeString = model.editedProject.deadlineString
                , timeErr = model.editedProject.deadlineErr
                , msg = T.ProjectsOnInputDeadlineString
                }
        , label []
            [ span [] [ text "Sztywny termin" ]
            , input
                [ type_ "checkbox"
                , checked data.is_deadline_rigid
                , onInput T.ProjectsOnInputIsDeadlineRigid
                ]
                []
            ]
        , model
            |> Dates.dateInputView
                { label = "Data rozpoczęcia"
                , time = data.start_at
                , timeString = model.editedProject.startAtString
                , timeErr = model.editedProject.startAtErr
                , msg = T.ProjectsOnInputStartAtString
                }
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
        , label []
            [ span [] [ text "Zarchiwizowany?" ]
            , input
                [ type_ "checkbox"
                , checked data.is_archived
                , onInput T.ProjectsOnInputIsArchived
                ]
                []
            ]
        ]


editProjectModalView : T.Model -> Html T.Msg
editProjectModalView model =
    div [ class "modal" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h3 [] [ text model.editedProject.data.name ]
                ]
            , div [ class "modal-body" ]
                [ Html.map (\msg -> T.ProjectsAction msg) (formView model) ]
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


emptyProject : Time.Posix -> T.Project
emptyProject initialTime =
    { id = 0
    , client_id = 0
    , name = ""
    , is_deadline_rigid = False
    , deadline = initialTime
    , invoice_number = ""
    , price = 0
    , paid = 0
    , tasks = []
    , is_archived = False
    , start_at = initialTime
    }
