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
    table [ class "projects-list" ]
        (List.foldr (mergeProjects expandedProjects) [] projects)


mergeProjects : ExpandedProjects -> Project -> List (Html Msg) -> List (Html Msg)
mergeProjects expandedProjects project all =
    projectView expandedProjects project ++ all


projectView : ExpandedProjects -> Project -> List (Html Msg)
projectView expandedProjects project =
    [ thead []
        [ tr []
            [ th
                [ onClick (ToggleProjectExpand project)
                , class
                    ("project-expander "
                        ++ (if Utils.isProjectExpanded project expandedProjects then
                                "icon caret-down"

                            else
                                "icon caret-right"
                           )
                    )
                ]
                []
            , th [ class "project-name", onClick (ToggleProjectExpand project) ]
                [ text project.name ]
            ]
        ]
    , if Utils.isProjectExpanded project expandedProjects then
        tbody []
            (List.map taskView project.tasks
                ++ [ addTaskButtonView project ]
            )

      else
        text ""
    ]


taskView : Task -> Html Msg
taskView task =
    tr [ class "task" ]
        [ td [] [ text "" ]
        , td [] [ text task.name ]
        ]


addTaskButtonView : Project -> Html Msg
addTaskButtonView project =
    tr []
        [ td [] [ text "" ]
        , td []
            [ button
                [ class "add-task-button"
                , onClick (Types.CreateNewTask project)
                ]
                [ text "➕ nowe zadanie"
                ]
            ]
        ]
