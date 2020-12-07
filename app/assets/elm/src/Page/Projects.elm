module Page.Projects exposing (Model, Msg, init, toSession, update, view)

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
import Session
import Set exposing (Set)
import Time
import ViewElements exposing (..)



-- MODEL


type MainViewState
    = LoadingState
    | FailureState
    | SuccessState


type alias PriceTrio =
    { paid : Float
    , finished : Float
    , total : Float
    }


type alias Model =
    { session : Session.Model
    , mainViewState : MainViewState
    , projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    , expandedProjects : Set Int
    }


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


init : Session.Model -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , mainViewState = SuccessState
      , projects = []
      , workers = []
      , statuses = []
      , clients = []
      , expandedProjects = Set.empty
      }
    , getCurrentProjectsRequest
    )


toSession : Model -> Session.Model
toSession model =
    model.session


expandCollapseProject : Project -> Set Int -> Set Int
expandCollapseProject project expandedProjects =
    if Set.member project.id expandedProjects then
        Set.remove project.id expandedProjects

    else
        Set.insert project.id expandedProjects



-- UPDATE


type Msg
    = NoOp
    | NewProject
    | CurrentProjectsReceived (Result Http.Error AllData)
    | ExpandCollapseProject Project
    | SelectTaskWorker ProjectTask String
    | SelectTaskStatus ProjectTask String
    | TaskUpdated (Result Http.Error ProjectTask)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewProject ->
            ( model, Cmd.none )

        CurrentProjectsReceived (Ok allData) ->
            ( { model
                | projects = allData.projects
                , workers = allData.workers
                , statuses = allData.statuses
                , clients = allData.clients
              }
            , Cmd.none
            )

        CurrentProjectsReceived (Err error) ->
            ( { model | mainViewState = FailureState }, Cmd.none )

        ExpandCollapseProject project ->
            ( { model | expandedProjects = expandCollapseProject project model.expandedProjects }, Cmd.none )

        SelectTaskWorker task workerId ->
            ( { model | mainViewState = LoadingState }
            , changeTaskWorkerRequest task workerId
            )

        SelectTaskStatus task statusId ->
            ( { model | mainViewState = LoadingState }
            , changeTaskStatusRequest task statusId
            )

        TaskUpdated (Err error) ->
            ( { model | mainViewState = FailureState }, Cmd.none )

        TaskUpdated (Ok task) ->
            ( { model | mainViewState = SuccessState } |> modifyTask task, Cmd.none )


modifyTask : ProjectTask -> Model -> Model
modifyTask task model =
    modifyProjectById task.project_id model (modifyTaskInProject task)


modifyProjectById : Int -> Model -> (Project -> Project) -> Model
modifyProjectById projectId model func =
    { model
        | projects =
            List.map
                (\p ->
                    if p.id == projectId then
                        func p

                    else
                        p
                )
                model.projects
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
        , expect = Http.expectJson CurrentProjectsReceived allDataDecoder
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
    if model.mainViewState == FailureState then
        el [] (text "wystąpił błąd (sprawdź połączenie)")

    else
        let
            loadingArgs =
                if model.mainViewState == LoadingState then
                    [ alpha 0.2, htmlAttribute (Html.Attributes.style "pointer-events" "none") ]

                else
                    []
        in
        column (width fill :: loadingArgs)
            (toolBar model :: List.map (projectView model) model.projects)


projectView : Model -> Project -> Element Msg
projectView model project =
    let
        isExpanded =
            Set.member project.id model.expandedProjects

        icon =
            if isExpanded then
                Icons.caretDownOutlined []

            else
                Icons.caretRightOutlined []

        subTasks =
            if isExpanded then
                List.map (\task -> taskView model task) project.tasks

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
            , el [ alignRight ] (text (Dates.displayDate (toSession model) project.deadline))
            ]
        , column
            [ width fill
            , paddingEach { top = 0, right = 0, bottom = 0, left = 20 }
            ]
            subTasks
        ]


taskView : Model -> ProjectTask -> Element Msg
taskView model task =
    row [ width fill ]
        [ el [] (text task.name)
        , el [ alignRight ] (text (Currency.format task.price ++ "zł"))
        , selectWorker model task
        , selectStatus model task
        ]


selectStatus : Model -> ProjectTask -> Element Msg
selectStatus model task =
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
                    model.statuses
            )
        )


selectWorker : Model -> ProjectTask -> Element Msg
selectWorker model task =
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
                    model.workers
            )
        )


pricesMini : String -> PriceTrio -> Element Msg
pricesMini header prices =
    row []
        [ el [] (text (Currency.format prices.paid ++ "/"))
        , el [] (text (Currency.format prices.finished ++ "/"))
        , el [] (text (Currency.format prices.total ++ "zł"))
        ]


toolBar : Model -> Element Msg
toolBar model =
    column [ width fill ]
        [ row [ width fill ]
            [ el [] (text "expand")
            , el [] (text "search")
            , el []
                (pricesMini "Suma kwot za wszystkie zlecenia"
                    { paid = Project.sumPaid model.projects
                    , finished = Project.sumFinished model.projects
                    , total = Project.sumPrice model.projects
                    }
                )
            ]
        , row [ width fill ]
            [ button
                { label = "dodaj zamówienie"
                , onPress = NewProject
                , icon = Icons.plusCircleOutlined
                }
            ]
        ]
