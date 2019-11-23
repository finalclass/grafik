module Utils exposing (hideModal, sendMsg)

import Task
import Types as T


hideModal : T.Model -> T.Model
hideModal model =
    { model | modal = T.ModalHidden }


sendMsg : T.Msg -> Cmd T.Msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity
