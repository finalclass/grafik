module ModalViewUtils exposing (hideModal)

import Types as T


hideModal : T.Model -> T.Model
hideModal model =
    { model | modal = T.ModalHidden }
