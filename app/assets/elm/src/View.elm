module View exposing (mainView)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModalView exposing (modalView)
import Types as T
import Utils


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
        [ modalView model
        , if model.mainViewState == T.FailureState then
            text "problem z połączeniem"

          else
            projectsView model
        ]


projectsView : T.Model -> Html T.Msg
projectsView model =
    table [ class "projects-list" ]
        (List.foldr (mergeProjects model) [] model.projects)


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
                        ++ (if Utils.isProjectExpanded project model.expandedProjects then
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
            , th [ colspan 3, class "project-buttons" ]
                [ a [ class "button", href ("/clients/" ++ String.fromInt project.client_id) ]
                    [ text "klient" ]
                , a [ class "button", href ("/projects/" ++ String.fromInt project.id) ]
                    [ text "zlecenie"
                    ]
                ]
            ]
        ]
    , if Utils.isProjectExpanded project model.expandedProjects then
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
                , span [] [ text "nowe zadanie" ]
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
                        , selected
                            (case task.worker of
                                Just worker ->
                                    worker.id == w.id

                                Nothing ->
                                    False
                            )
                        ]
                        [ text w.name ]
                )
                model.workers
        )
