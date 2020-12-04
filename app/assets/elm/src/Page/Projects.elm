module Page.Projects exposing (Model, Msg, init, toSession, update, view)

import Ant.Icons as Icons
import Dates
import Element exposing (Element, alignRight, column, el, fill, row, text, width)
import Http
import Json.Decode as D
import Json.Decode.Pipeline exposing (optional, required)
import Session exposing (Session)
import Time
import ViewElements exposing (..)



-- MODEL


type MainViewState
    = LoadingState
    | FailureState
    | SuccessState


type alias Model =
    { session : Session
    , mainViewState : MainViewState
    , projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    }


type alias Project =
    { id : Int
    , client_id : Int
    , name : String
    , description : String
    , is_deadline_rigid : Bool
    , deadline : Time.Posix
    , invoice_number : String
    , price : Float
    , paid : Float
    , tasks : List Task
    , is_archived : Bool
    , start_at : Time.Posix
    }


type alias Client =
    { id : Int
    , name : String
    , invoice_name : String
    , invoice_street : String
    , invoice_postcode : String
    , invoice_city : String
    , invoice_nip : String
    , delivery_name : String
    , delivery_street : String
    , delivery_postcode : String
    , delivery_city : String
    , delivery_contact_person : String
    , phone_number : String
    , email : String
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


type alias Task =
    { id : Int
    , project_id : Int
    , worker_id : Int
    , name : String
    , status : String
    , sent_note : String
    , price : Float
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , mainViewState = SuccessState
      , projects = []
      , workers = []
      , statuses = []
      , clients = []
      }
    , getCurrentProjects
    )


toSession : Model -> Session
toSession model =
    model.session



-- UPDATE


type Msg
    = NoOp
    | NewProject
    | CurrentProjectsReceived (Result Http.Error AllData)


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



-- REQUESTS


getCurrentProjects : Cmd Msg
getCurrentProjects =
    Http.get
        { url = "/api/all"
        , expect = Http.expectJson CurrentProjectsReceived projectsDecoder
        }


projectsDecoder : D.Decoder AllData
projectsDecoder =
    D.map4 AllData
        (D.field "projects"
            (D.list projectDecoder)
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
        (D.field "clients"
            (D.list
                clientDecoder
            )
        )


taskDecoder : D.Decoder Task
taskDecoder =
    D.map7 Task
        (D.field "id" D.int)
        (D.field "project_id" D.int)
        (D.field "worker_id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "sent_note" D.string)
        (D.field "price" D.float)


decodeTime : D.Decoder Time.Posix
decodeTime =
    D.int
        |> D.andThen
            (\ms ->
                D.succeed <| Time.millisToPosix ms
            )


projectDecoder : D.Decoder Project
projectDecoder =
    D.succeed Project
        |> required "id" D.int
        |> required "client_id" D.int
        |> required "name" D.string
        |> required "description" D.string
        |> required "is_deadline_rigid" D.bool
        |> required "deadline" decodeTime
        |> optional "invoice_number" D.string ""
        |> optional "price" D.float 0
        |> optional "paid" D.float 0
        |> required "tasks" (D.list taskDecoder)
        |> required "is_archived" D.bool
        |> required "start_at" decodeTime


clientDecoder : D.Decoder Client
clientDecoder =
    D.succeed Client
        |> required "id" D.int
        |> required "name" D.string
        |> optional "invoice_name" D.string ""
        |> optional "invoice_street" D.string ""
        |> optional "invoice_postcode" D.string ""
        |> optional "invoice_city" D.string ""
        |> optional "invoice_nip" D.string ""
        |> optional "delivery_name" D.string ""
        |> optional "delivery_street" D.string ""
        |> optional "delivery_postcode" D.string ""
        |> optional "delivery_city" D.string ""
        |> optional "delivery_contact_person" D.string ""
        |> optional "phone_number" D.string ""
        |> optional "email" D.string ""



-- VIEW


view : Model -> Element Msg
view model =
    case model.mainViewState of
        LoadingState ->
            el [] (text "ładowanie...")

        FailureState ->
            el [] (text "wystąpił błąd (sprawdź połączenie)")

        SuccessState ->
            column [ width fill ]
                (toolBar model :: List.map (projectView model) model.projects)


projectView : Model -> Project -> Element Msg
projectView model project =
    row [ width fill ]
        [ Icons.caretRightOutlined []
        , text project.name
        , el [ alignRight ] (text (Dates.displayDate (toSession model) project.deadline))
        ]


toolBar : Model -> Element Msg
toolBar model =
    column [ width fill ]
        [ row [ width fill ]
            [ el [] (text "expand")
            , el [] (text "search")
            , el [] (text "prices mini")
            ]
        , row [ width fill ]
            [ button
                { label = "dodaj zamówienie"
                , onPress = NewProject
                , icon = Icons.plusCircleOutlined
                }
            ]
        ]
