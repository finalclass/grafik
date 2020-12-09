module Page.Workers exposing (Model, Msg, init, toSession, update, updateSession, view)

import Element exposing (Element, el, text)
import Session exposing (Session)


type alias Model =
    { session : Session
    }


type Msg
    = NoOp


toSession : Model -> Session
toSession model =
    model.session


updateSession : Model -> Session -> Model
updateSession model session =
    { model | session = session }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }, Cmd.none )


view : Model -> Element Msg
view model =
    el [] (text "Workers")
