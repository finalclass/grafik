module Page.Projects exposing (Model, Msg, init, toSession, update, view)

import Ant.Icons as Icons
import Element exposing (Element, column, el, fill, row, text, width)
import Session exposing (Session)
import ViewElements exposing (..)



-- MODEL


type MainViewState
    = LoadingState
    | FailureState
    | SuccessState


type alias Model =
    { session : Session
    , mainViewState : MainViewState
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , mainViewState = SuccessState
      }
    , Cmd.none
    )


toSession : Model -> Session
toSession model =
    model.session



-- UPDATE


type Msg
    = NoOp
    | NewProject


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewProject ->
            ( model, Cmd.none )



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
                [ toolBar model
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
