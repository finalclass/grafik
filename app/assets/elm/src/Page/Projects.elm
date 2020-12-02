module Page.Projects exposing (Model, Msg, init, toSession, update, view)

import Element exposing (Element, el, text)
import Session exposing (Session)


type Msg
    = NoOp


type alias Model =
    { session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }, Cmd.none )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Element Msg
view model =
    el [] (text "Projects")
