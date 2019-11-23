module View exposing (mainView)

import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModalView exposing (modalView)
import Model as M
import Types as T


mainView : T.Model -> Html T.Msg
mainView model =
    div
        [ class
            ("dashboard "
                ++ (if model.mainViewState == T.LoadingState then
                        "loading"

                    else
                        ""
                   )
            )
        ]
        (modalView model
            :: (if model.mainViewState == T.FailureState then
                    [ text "problem z połączeniem" ]

                else
                    [ searchBoxView model
                    , button
                        [ class "button-small button-outline"
                        , onClick (T.ProjectsAction T.ProjectsNewProject)
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text "dodaj zlecenie"
                        ]
                    , projectsView model
                    ]
               )
        )


searchBoxView : T.Model -> Html T.Msg
searchBoxView model =
    div [ class "search-box" ]
        [ input
            [ type_ "text"
            , placeholder "szukaj..."
            , value model.searchText
            , onInput T.SearchEnterText
            , class
                (if String.length model.searchText > 0 then
                    "filtering-is-on"

                 else
                    ""
                )
            ]
            []
        , if M.nofHiddenProjects model > 0 then
            i [ class "hidden-projects-info" ]
                [ text ("(ukrytych: " ++ String.fromInt (M.nofHiddenProjects model) ++ ")")
                ]

          else
            text ""
        ]


projectsView : T.Model -> Html T.Msg
projectsView model =
    table [ class "projects-list" ]
        (List.foldr (mergeProjects model) [] (M.getVisibleProjects model))


mergeProjects : T.Model -> T.Project -> List (Html T.Msg) -> List (Html T.Msg)
mergeProjects model project all =
    projectView model project ++ all


projectView : T.Model -> T.Project -> List (Html T.Msg)
projectView model project =
    [ thead []
        [ tr [ class "project-row" ]
            [ th
                [ onClick (T.ToggleProjectExpand project)
                , class
                    ("project-expander "
                        ++ (if M.isProjectExpanded project model.expandedProjects then
                                "icon caret-down"

                            else
                                "icon caret-right"
                           )
                    )
                ]
                []
            , th
                [ class "project-name"
                , onClick (T.ToggleProjectExpand project)
                ]
                [ text project.name ]
            , th
                [ class
                    ("project-deadline "
                        ++ (if project.is_deadline_rigid then
                                "rigid-deadline"

                            else
                                ""
                           )
                    )
                , title "Termin"
                ]
                [ text (Dates.displayDate model project.deadline) ]
            , th [ colspan 2, class "project-buttons" ]
                [ a
                    [ class "button button-outline"
                    , title "Edycja zlecenia"
                    , onClick (T.ProjectsAction (T.ProjectsStartEdit project))
                    ]
                    [ text "edytuj" ]
                ]
            ]
        ]
    , if M.isProjectExpanded project model.expandedProjects then
        tbody []
            (List.map (taskView model) project.tasks
                ++ [ addTaskButtonView project ]
            )

      else
        text ""
    ]


taskView : T.Model -> T.Task -> Html T.Msg
taskView model task =
    tr [ class ("task task-" ++ task.status) ]
        [ td [] [ text "" ]
        , td [ class "task-name", onClick (T.TaskRenameModalShow task) ] [ text task.name ]
        , td [ class "task-worker-select-container" ] [ selectWorkerView model task ]
        , td [ class "task-status-select-container" ] [ selectTaskStatusView model task ]
        , td [ class "task-remove-button-container" ]
            [ button
                [ class "button-outline"
                , title "Usuń"
                , onClick (T.TaskRemoveRequest task)
                ]
                [ i [ class "icon remove" ] []
                ]
            ]
        ]


selectTaskStatusView : T.Model -> T.Task -> Html T.Msg
selectTaskStatusView model task =
    select [ onInput (T.TaskChangeStatusRequest task) ]
        (List.map
            (\s ->
                option [ value s.id, selected (task.status == s.id) ]
                    [ text s.name ]
            )
            model.statuses
        )


addTaskButtonView : T.Project -> Html T.Msg
addTaskButtonView project =
    tr []
        [ td [] [ text "" ]
        , td [ colspan 4, class "add-task-button-container" ]
            [ button
                [ class "add-task-button"
                , onClick (T.TaskCreateRequest project)
                ]
                [ i [ class "icon icon-plus" ]
                    []
                , span [] [ text "dodaj zadanie" ]
                ]
            ]
        ]


selectWorkerView : T.Model -> T.Task -> Html T.Msg
selectWorkerView model task =
    select [ onInput (T.TaskSetWorkerRequest task) ]
        (option [] []
            :: List.map
                (\w ->
                    option
                        [ value (String.fromInt w.id)
                        , selected (task.worker_id == w.id)
                        ]
                        [ text w.name ]
                )
                model.workers
        )
