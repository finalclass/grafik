module View exposing (mainView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Utils


mainView : Model -> Html Msg
mainView model =
    div []
        [ h2 []
            [ i [ class "icon-caret-right" ] []
            , text "Projects"
            ]
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
    ul [ class "projects-list" ]
        (List.map (projectView expandedProjects) projects)


projectView : ExpandedProjects -> Project -> Html Msg
projectView expandedProjects project =
    li []
        [ projectExpanderView project expandedProjects
        , case Utils.isProjectExpanded project expandedProjects of
            True ->
                ul [] (List.map taskView project.tasks)

            False ->
                text ""
        ]


projectExpanderView project expandedProjects =
    div [ class "project-expander", onClick (ToggleProjectExpand project) ]
        [ i
            [ class
                (case Utils.isProjectExpanded project expandedProjects of
                    True ->
                        "icon caret-down"

                    False ->
                        "icon caret-right"
                )
            ]
            []
        , text project.name
        ]


taskView : Task -> Html Msg
taskView task =
    li []
        [ text task.name ]
