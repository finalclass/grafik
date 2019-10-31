module Main exposing (..)

import Browser
import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Projects (List Project)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getAllProjects )



-- UPDATE


type Msg
    = GotProjects (Result Http.Error (List Project))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotProjects result ->
            case Debug.log "abc" result of
                Ok projects ->
                    ( Projects projects, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Projects" ]
        , case model of
            Projects projects ->
                renderProjects projects

            Failure ->
                text "loading failed"

            Loading ->
                text "loading"
        ]


renderProjects : List Project -> Html Msg
renderProjects projects =
    ul []
        (List.map renderProject projects)


renderProject : Project -> Html Msg
renderProject project =
    li []
        [ span [] [ text project.name ]
        , ul [] (List.map renderTask project.tasks)
        ]


renderTask : Task -> Html Msg
renderTask task =
    li []
        [ text task.name ]



-- HTTP


getAllProjects : Cmd Msg
getAllProjects =
    Http.get
        { url = "/api/projects"
        , expect = Http.expectJson GotProjects projectsDecoder
        }


type alias Worker =
    { id : Int
    , name : String
    }


type alias Task =
    { id : Int
    , name : String
    , status : String
    , worker : Worker
    }


type alias Client =
    { id : Int
    , name : String
    }


type alias Project =
    { id : Int
    , name : String
    , client : Client
    , tasks : List Task
    }


projectsDecoder : D.Decoder (List Project)
projectsDecoder =
    D.field "data"
        (D.list
            (D.map4 Project
                (D.field "id" D.int)
                (D.field "name" D.string)
                (D.field "client"
                    (D.map2 Client
                        (D.field "id" D.int)
                        (D.field "name" D.string)
                    )
                )
                (D.field "tasks"
                    (D.list
                        (D.map4 Task
                            (D.field "id" D.int)
                            (D.field "name" D.string)
                            (D.field "status" D.string)
                            (D.field "worker"
                                (D.map2 Worker
                                    (D.field "id" D.int)
                                    (D.field "name" D.string)
                                )
                            )
                        )
                    )
                )
            )
        )
