module Page.Workers exposing (Model, Msg, init, toSession, update, view)

import Element exposing (Element, el, text)
import Session


type alias Model =
    { session : Session.Model
    }


type Msg
    = NoOp


toSession : Model -> Session.Model
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


init : Session.Model -> ( Model, Cmd Msg )
init session =
    ( { session = session }, Cmd.none )


view : Model -> Element Msg
view model =
    el [] (text "Workers")
