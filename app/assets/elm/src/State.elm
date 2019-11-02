module State exposing (init, update)

import Debug exposing (log)
import Dict
import Requests
import Types exposing (..)
import Utils


init : () -> ( Model, Cmd Msg )
init flags =
    ( Loading, Requests.getAllProjects )


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
                            Utils.isProjectExpanded project expandedProjects

                        newExpandedProjects =
                            Dict.insert project.id (not isExpanded) expandedProjects
                    in
                    ( Success { successModel | expandedProjects = newExpandedProjects }, Cmd.none )
