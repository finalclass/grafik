module Tasks.State exposing (..)

import Tasks.Requests as R
import Tasks.Types exposing (..)
import Types


init =
    ( { mainViewState = LoadingState
      }
    , Cmd.map (\cmd -> Types.TasksMsg cmd) R.getCurrentProjects
    )


update msg model =
    case msg of
        None ->
            ( model, Cmd.none )
