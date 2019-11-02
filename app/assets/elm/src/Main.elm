module Main exposing (main)

import Browser
import State
import Types
import View


main : Program String Types.Model Types.Msg
main =
    Browser.element
        { init = State.init
        , update = State.update
        , subscriptions = subscriptions
        , view = View.mainView
        }


subscriptions : Types.Model -> Sub Types.Msg
subscriptions _ =
    Sub.none
