module Main exposing (..)

import Browser
import Debug exposing (log)
import Dict exposing (Dict)
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


type alias ExpandedProjects =
    Dict Int Bool


type alias ModelValue =
    { projects : List Project
    , expandedProjects : ExpandedProjects
    }


type Model
    = Loading
    | Failure
    | Success ModelValue


init : () -> ( Model, Cmd Msg )
init flags =
    ( Loading, getAllProjects )



-- UPDATE


type Msg
    = ToggleProjectExpand Project
    | GotProjects (Result Http.Error (List Project))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotProjects result ->
            case Debug.log "projects" result of
                Ok projects ->
                    ( Success { projects = projects, expandedProjects = Dict.empty }, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        ToggleProjectExpand project ->
            case model of
                Failure ->
                    ( Failure, Cmd.none )

                Loading ->
                    ( Loading, Cmd.none )

                Success successModel ->
                    let
                        expandedProjects =
                            successModel.expandedProjects

                        isExpanded =
                            isProjectExpanded project expandedProjects

                        newExpandedProjects =
                            Dict.insert project.id (not isExpanded) expandedProjects
                    in
                    ( Success { successModel | expandedProjects = newExpandedProjects }, Cmd.none )



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
            Success { projects, expandedProjects } ->
                projectsView projects expandedProjects

            Failure ->
                text "loading failed"

            Loading ->
                text "loading"
        ]


projectsView : List Project -> ExpandedProjects -> Html Msg
projectsView projects expandedProjects =
    ul []
        (List.map (projectView expandedProjects) projects)


projectView : ExpandedProjects -> Project -> Html Msg
projectView expandedProjects project =
    li []
        [ span [] [ text project.name ]
        , toggleExpandButtonView project expandedProjects
        , case isProjectExpanded project expandedProjects of
            True ->
                ul [] (List.map renderTask project.tasks)

            False ->
                text ""
        ]


toggleExpandButtonView : Project -> ExpandedProjects -> Html Msg
toggleExpandButtonView project expandedProjects =
    button [ onClick (ToggleProjectExpand project) ]
        [ text
            (case isProjectExpanded project expandedProjects of
                True ->
                    "collapse"

                False ->
                    "expand"
            )
        ]


isProjectExpanded : Project -> ExpandedProjects -> Bool
isProjectExpanded project expandedProjects =
    case Dict.get project.id expandedProjects of
        Just value ->
            value

        Nothing ->
            False


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
