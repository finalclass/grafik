module Page.Projects exposing (Model, Msg, init, toSession, update, updateSession, view)

import Ant.Icons as Icons
import Client exposing (Client)
import Currency
import Dates
import Element exposing (Element, alignRight, alpha, column, el, fill, html, htmlAttribute, map, paddingEach, pointer, row, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Project exposing (Project)
import ProjectTask exposing (ProjectTask)
import Session exposing (Session)
import Set exposing (Set)
import Time
import ViewElements exposing (..)



-- MODEL


type MainViewState
    = LoadingState
    | SuccessState


type alias PriceTrio =
    { paid : Float
    , finished : Float
    , total : Float
    }


type Model
    = InitializingModel InitData
    | FailedModel Session
    | ReadyModel ModelData


type alias InitData =
    { session : Session
    , allData : Maybe AllData
    }


type alias ModelData =
    { session : Session
    , mainViewState : MainViewState
    , projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    , expandedProjects : Set Int
    , projectsType : ProjectsType
    }


type ProjectsType
    = CurrentProjects
    | ArchivedProjects


type alias AllData =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    }


type alias Status =
    { id : String
    , name : String
    }


type alias Worker =
    { id : Int
    , name : String
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( InitializingModel { session = session, allData = Nothing }, getCurrentProjectsRequest )


toSession : Model -> Session
toSession model =
    case model of
        InitializingModel initData ->
            initData.session

        FailedModel session ->
            session

        ReadyModel modelData ->
            modelData.session


updateSession : Model -> Session -> Model
updateSession model session =
    case model of
        InitializingModel initData ->
            InitializingModel { initData | session = session }

        FailedModel _ ->
            FailedModel session

        ReadyModel modelData ->
            ReadyModel { modelData | session = session }


expandCollapseProject : Project -> Set Int -> Set Int
expandCollapseProject project expandedProjects =
    if Set.member project.id expandedProjects then
        Set.remove project.id expandedProjects

    else
        Set.insert project.id expandedProjects



-- UPDATE


type Msg
    = NoOp
    | LoadCurrentProjects
    | LoadArchivedProjects
    | NewProject
    | AllDataReceived ProjectsType (Result Http.Error AllData)
    | ExpandCollapseProject Project
    | SelectTaskWorker ProjectTask String
    | SelectTaskStatus ProjectTask String
    | TaskUpdated (Result Http.Error ProjectTask)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( LoadCurrentProjects, ReadyModel _ ) ->
            ( InitializingModel { session = toSession model, allData = Nothing }, getCurrentProjectsRequest )

        ( LoadArchivedProjects, ReadyModel _ ) ->
            ( InitializingModel { session = toSession model, allData = Nothing }, getArchivedProjectsRequest )

        ( AllDataReceived projectsType (Ok allData), _ ) ->
            ( ReadyModel
                { projects = allData.projects
                , workers = allData.workers
                , statuses = allData.statuses
                , clients = allData.clients
                , projectsType = projectsType
                , mainViewState = SuccessState
                , session = toSession model
                , expandedProjects = Set.empty
                }
            , Cmd.none
            )

        ( AllDataReceived _ (Err error), _ ) ->
            ( FailedModel (toSession model), Cmd.none )

        ( NewProject, _ ) ->
            ( model, Cmd.none )

        ( ExpandCollapseProject project, ReadyModel modelData ) ->
            ( ReadyModel { modelData | expandedProjects = expandCollapseProject project modelData.expandedProjects }
            , Cmd.none
            )

        ( SelectTaskWorker task workerId, ReadyModel modelData ) ->
            ( ReadyModel { modelData | mainViewState = LoadingState }
            , changeTaskWorkerRequest task workerId
            )

        ( SelectTaskStatus task statusId, ReadyModel modelData ) ->
            ( ReadyModel { modelData | mainViewState = LoadingState }
            , changeTaskStatusRequest task statusId
            )

        ( TaskUpdated (Err error), ReadyModel _ ) ->
            ( FailedModel (toSession model), Cmd.none )

        ( TaskUpdated (Ok task), ReadyModel modelData ) ->
            ( ReadyModel ({ modelData | mainViewState = SuccessState } |> modifyTask task)
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


modifyTask : ProjectTask -> ModelData -> ModelData
modifyTask task modelData =
    modifyProjectById task.project_id modelData (modifyTaskInProject task)


modifyProjectById : Int -> ModelData -> (Project -> Project) -> ModelData
modifyProjectById projectId modelData func =
    { modelData
        | projects =
            List.map
                (\p ->
                    if p.id == projectId then
                        func p

                    else
                        p
                )
                modelData.projects
    }


modifyTaskInProject : ProjectTask -> Project -> Project
modifyTaskInProject task project =
    { project
        | tasks =
            List.map
                (\t ->
                    if t.id == task.id then
                        task

                    else
                        t
                )
                project.tasks
    }



-- REQUESTS


changeTaskWorkerRequest : ProjectTask -> String -> Cmd Msg
changeTaskWorkerRequest task workerId =
    modifyTaskRequest task [ ( "worker_id", E.string workerId ) ]


changeTaskStatusRequest : ProjectTask -> String -> Cmd Msg
changeTaskStatusRequest task statusId =
    modifyTaskRequest task [ ( "status_id", E.string statusId ) ]


modifyTaskRequest : ProjectTask -> List ( String, E.Value ) -> Cmd Msg
modifyTaskRequest task fields =
    Http.request
        { method = "PUT"
        , url = "/api/projects/" ++ String.fromInt task.project_id ++ "/tasks/" ++ String.fromInt task.id
        , body =
            Http.jsonBody
                (E.object
                    [ ( "task", E.object fields ) ]
                )
        , headers = []
        , expect = Http.expectJson TaskUpdated ProjectTask.decoder
        , timeout = Nothing
        , tracker = Nothing
        }


getCurrentProjectsRequest : Cmd Msg
getCurrentProjectsRequest =
    Http.get
        { url = "/api/all"
        , expect = Http.expectJson (AllDataReceived CurrentProjects) allDataDecoder
        }


getArchivedProjectsRequest : Cmd Msg
getArchivedProjectsRequest =
    Http.get
        { url = "/api/all?archived=true"
        , expect = Http.expectJson (AllDataReceived ArchivedProjects) allDataDecoder
        }


allDataDecoder : D.Decoder AllData
allDataDecoder =
    D.map4 AllData
        (D.field "projects"
            (D.list Project.decoder)
        )
        (D.field "workers"
            (D.list
                (D.map2 Worker
                    (D.field "id" D.int)
                    (D.field "name" D.string)
                )
            )
        )
        (D.field "statuses"
            (D.list
                (D.map2 Status
                    (D.field "id" D.string)
                    (D.field "name" D.string)
                )
            )
        )
        (D.field "clients" (D.list Client.decoder))



-- VIEW


view : Model -> Element Msg
view model =
    case model of
        InitializingModel _ ->
            el [] (text "ładowanie...")

        FailedModel _ ->
            el [] (text "wystąpił błąd (sprawdź połączenie)")

        ReadyModel modelData ->
            let
                loadingArgs =
                    if modelData.mainViewState == LoadingState then
                        [ alpha 0.2, htmlAttribute (Html.Attributes.style "pointer-events" "none") ]

                    else
                        []
            in
            column (width fill :: loadingArgs)
                (toolBar modelData :: List.map (projectView modelData) modelData.projects)


projectView : ModelData -> Project -> Element Msg
projectView modelData project =
    let
        isExpanded =
            Set.member project.id modelData.expandedProjects

        icon =
            if isExpanded then
                Icons.caretDownOutlined []

            else
                Icons.caretRightOutlined []

        subTasks =
            if isExpanded then
                List.map (\task -> taskView modelData task) project.tasks

            else
                []
    in
    column [ width fill ]
        [ row [ width fill ]
            [ el [ onClick (ExpandCollapseProject project) ]
                icon
            , el [ onClick (ExpandCollapseProject project), Font.bold ] (text project.name)
            , pricesMini "Za zlecenie"
                { paid = project.paid
                , finished = ProjectTask.sumFinished project.tasks
                , total = Project.price project
                }
            , el [ alignRight ] (text (Dates.displayDate (toSession (ReadyModel modelData)) project.deadline))
            ]
        , column
            [ width fill
            , paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
            ]
            subTasks
        ]


taskView : ModelData -> ProjectTask -> Element Msg
taskView modelData task =
    row [ width fill ]
        [ el [] (text task.name)
        , el [ alignRight ] (text (Currency.format task.price ++ "zł"))
        , selectWorker modelData task
        , selectStatus modelData task
        ]


selectStatus : ModelData -> ProjectTask -> Element Msg
selectStatus modelData task =
    html
        (Html.select [ Html.Events.onInput (SelectTaskStatus task) ]
            (Html.option [] []
                :: List.map
                    (\status ->
                        Html.option
                            [ Html.Attributes.value status.id
                            , Html.Attributes.selected (status.id == task.status)
                            ]
                            [ Html.text status.name ]
                    )
                    modelData.statuses
            )
        )


selectWorker : ModelData -> ProjectTask -> Element Msg
selectWorker modelData task =
    html
        (Html.select [ Html.Events.onInput (SelectTaskWorker task) ]
            (Html.option [] []
                :: List.map
                    (\worker ->
                        Html.option
                            [ Html.Attributes.value (String.fromInt worker.id)
                            , Html.Attributes.selected (worker.id == task.worker_id)
                            ]
                            [ Html.text worker.name ]
                    )
                    modelData.workers
            )
        )


pricesMini : String -> PriceTrio -> Element Msg
pricesMini header prices =
    row []
        [ el [] (text (Currency.format prices.paid ++ "/"))
        , el [] (text (Currency.format prices.finished ++ "/"))
        , el [] (text (Currency.format prices.total ++ "zł"))
        ]


toolBar : ModelData -> Element Msg
toolBar modelData =
    column [ width fill ]
        [ row [ width fill ]
            [ el [] (text "expand")
            , el [] (text "search")
            , el []
                (pricesMini "Suma kwot za wszystkie zlecenia"
                    { paid = Project.sumPaid modelData.projects
                    , finished = Project.sumFinished modelData.projects
                    , total = Project.sumPrice modelData.projects
                    }
                )
            ]
        , row [ width fill ]
            [ button
                { label = "dodaj zamówienie"
                , onPress = NewProject
                , icon = Icons.plusCircleOutlined
                }
            , el [ alignRight ]
                (button
                    (case modelData.projectsType of
                        CurrentProjects ->
                            { label = "wyświetlam bierzące"
                            , onPress = LoadArchivedProjects
                            , icon = Icons.scissorOutlined
                            }

                        ArchivedProjects ->
                            { label = "wyświetlam archiwalne"
                            , onPress = LoadCurrentProjects
                            , icon = Icons.hourglassOutlined
                            }
                    )
                )
            ]
        ]
