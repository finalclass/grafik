module View exposing (mainView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types as T
import Utils


mainView : T.Model -> Html T.Msg
mainView model =
    div []
        [ h2 []
            [ i [ class "icon-caret-right" ] []
            , text "Projects"
            ]
        , case model.mainViewState of
            T.MainViewShowProjects ->
                projectsView model.projects model.expandedProjects

            T.MainViewShowFailure ->
                text "loading failed"

            T.MainViewShowLoading ->
                text "loading"
        ]


projectsView : List T.Project -> T.ExpandedProjects -> Html T.Msg
projectsView projects expandedProjects =
    table [ class "projects-list" ]
        (List.foldr (mergeProjects expandedProjects) [] projects)


mergeProjects : T.ExpandedProjects -> T.Project -> List (Html T.Msg) -> List (Html T.Msg)
mergeProjects expandedProjects project all =
    projectView expandedProjects project ++ all


projectView : T.ExpandedProjects -> T.Project -> List (Html T.Msg)
projectView expandedProjects project =
    [ thead []
        [ tr []
            [ th
                [ onClick (T.ToggleProjectExpand project)
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
            , th
                [ class "project-name"
                , colspan 2
                , onClick (T.ToggleProjectExpand project)
                ]
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


taskView : T.Task -> Html T.Msg
taskView task =
    tr [ class "task" ]
        [ td [] [ text "" ]
        , td [] [ text task.name ]
        , td []
            [ button
                [ class "button-outline"
                , title "Usuń"
                , onClick (T.TaskRemoveRequest task)
                ]
                [ i [ class "icon remove" ] []
                ]
            ]
        ]


addTaskButtonView : T.Project -> Html T.Msg
addTaskButtonView project =
    tr []
        [ td [] [ text "" ]
        , td [ colspan 2 ]
            [ button
                [ class "add-task-button"
                , onClick (T.TaskCreateRequest project)
                ]
                [ text "➕ nowe zadanie"
                ]
            ]
        ]
