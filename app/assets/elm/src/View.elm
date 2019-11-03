module View exposing (mainView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
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
        [ tr []
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
                , colspan 3
                , onClick (T.ToggleProjectExpand project)
                ]
                [ text project.name ]
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
    tr [ class "task" ]
        [ td [] [ text "" ]
        , td [ class "task-name", onClick (T.TaskRenameModalShow task) ] [ text task.name ]
        , td []
            [ selectWorkerView model task
            ]
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
        , td [ colspan 3 ]
            [ button
                [ class "add-task-button"
                , onClick (T.TaskCreateRequest project)
                ]
                [ text "➕ nowe zadanie"
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
