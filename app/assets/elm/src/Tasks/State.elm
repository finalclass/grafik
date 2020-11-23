module Tasks.State exposing (..)

import Tasks.Types exposing (..)


init =
    {}


update msg model =
    case msg of
        None ->
            ( model, Cmd.none )
