module Projects exposing (emptyProject, formView, update)

import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types as T


update : T.ProjectsMsg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.ProjectsStartEdit project ->
            ( { model | modal = T.ModalEditProject project, editedProject = project }, Cmd.none )

        T.ProjectsSaveRequest project ->
            ( model, Cmd.none )

        T.ProjectsOnInputName str ->
            let
                editedProject =
                    model.editedProject

                newEditedProject =
                    { editedProject | name = str }
            in
            ( { model | editedProject = newEditedProject }, Cmd.none )


formView : T.Model -> Html T.ProjectsMsg
formView model =
    div []
        [ label []
            [ span [] [ text "Nazwa" ]
            , input [ type_ "text", value model.editedProject.name, onInput T.ProjectsOnInputName ] []
            ]
        , label []
            [ span [] [ text "Sztywny termin" ]
            , input [ type_ "checkbox", checked model.editedProject.is_deadline_rigid ] []
            ]
        , label []
            [ span [] [ text "Termin" ]
            , input [ type_ "text", value (Dates.displayDate model model.editedProject.deadline) ] []
            ]
        , label []
            [ span [] [ text "Numer faktury / oferty" ]
            , input [ type_ "text", value model.editedProject.invoice_number ] []
            ]
        , label []
            [ span [] [ text "Cena" ]
            , input [ type_ "number", step "0.01", value (String.fromFloat model.editedProject.price) ] []
            ]
        , label []
            [ span [] [ text "Zapłacono" ]
            , input [ type_ "number", step "0.01", value (String.fromFloat model.editedProject.paid) ] []
            ]
        ]


emptyProject : T.Project
emptyProject =
    { id = 0
    , client_id = 0
    , name = ""
    , is_deadline_rigid = False
    , deadline = Time.millisToPosix 0
    , invoice_number = ""
    , price = 0
    , paid = 0
    , tasks = []
    }
