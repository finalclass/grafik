module View exposing (mainView)

import Dates
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModalView exposing (modalView)
import Types as T
import Utils as U


addPriceZeros : String -> String
addPriceZeros str =
    if String.length str == 0 then
        "00"

    else if String.length str == 1 then
        str ++ "0"

    else if String.length str == 2 then
        str

    else
        String.left 2 str


splitStringEvery : Int -> String -> String -> String
splitStringEvery nofChars separator str =
    if String.length str < nofChars then
        str

    else
        splitStringEvery nofChars separator (String.dropRight nofChars str)
            ++ separator
            ++ String.right nofChars str


formatPrice : Float -> String
formatPrice price =
    let
        split =
            price |> String.fromFloat |> String.split "."

        int =
            split
                |> List.head
                |> Maybe.withDefault "0"

        intSeparated =
            splitStringEvery 3 " " int

        rest =
            split
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault "00"
                |> addPriceZeros
    in
    intSeparated ++ "." ++ rest


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
                    [ div [ class "container" ]
                        [ div [ class "row" ]
                            [ expandAllButtonView model
                            , searchBoxView model
                            , totalPriceView model
                            ]
                        ]
                    , button
                        [ class "button-small button-outline"
                        , onClick (T.ProjectsAction T.ProjectsNewProject)
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text "dodaj zamówienie"
                        ]
                    , button
                        [ class ("button-small float-right " ++ U.caseProjectsType model.projectsType "button-outline" "")
                        , title ("Przełącz na " ++ U.caseProjectsType model.projectsType "archiwalne" " bieżące")
                        , onClick T.ToggleProjectsType
                        ]
                        [ text
                            ("wyświetlam " ++ U.caseProjectsType model.projectsType "bieżące" "archiwalne")
                        ]
                    , projectsView model
                    ]
               )
        )


expandAllButtonView : T.Model -> Html T.Msg
expandAllButtonView model =
    div
        [ class
            "button-expand-all"
        , onClick T.ToggleExpandAllProjects
        , title
            (if U.allProjectsExpanded model then
                "Zwiń wszystko"

             else
                "Rozwiń wszystko"
            )
        ]
        [ i
            [ class
                ("icon "
                    ++ (if U.allProjectsExpanded model then
                            "caret-down"

                        else
                            "caret-right"
                       )
                )
            ]
            []
        , text
            (if U.allProjectsExpanded model then
                "zwiń"

             else
                "rozwiń"
            )
        ]


totalPriceView : T.Model -> Html T.Msg
totalPriceView model =
    div
        [ class "total-price"
        , title "SUMA: zapłacono / wykonano / kwota całkowita"
        ]
        [ text
            (U.formatPrice (U.sumProjectsPaid model)
                ++ " / "
                ++ U.formatPrice (U.sumAllFinished model)
                ++ " / "
                ++ U.formatPrice (U.sumProjectsPrice model)
                ++ " PLN"
            )
        ]


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
        , if U.nofHiddenProjects model > 0 then
            i [ class "hidden-projects-info" ]
                [ text ("(ukrytych: " ++ String.fromInt (U.nofHiddenProjects model) ++ ")")
                ]

          else
            text ""
        ]


projectsView : T.Model -> Html T.Msg
projectsView model =
    table [ class "projects-list" ]
        (List.foldr (mergeProjects model) [] (U.getVisibleProjects model))


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
                        ++ (if U.isProjectExpanded project model.expandedProjects then
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
                [ text (project.name ++ " ")
                , span
                    [ class "project-details project-invoice_number"
                    , title "numer faktury"
                    ]
                    [ text
                        (if String.length project.invoice_number > 0 then
                            "(" ++ project.invoice_number ++ ") "

                         else
                            ""
                        )
                    ]
                , span
                    [ class "project-details project-prices"
                    , title "ZLECENIE: zapłacono / kwota wykonana / kwota całkowita"
                    ]
                    [ text
                        ("("
                            ++ U.formatPrice project.paid
                            ++ " / "
                            ++ U.formatPrice (U.sumFinishedTasks project.tasks)
                            ++ " / "
                            ++ U.formatPrice (U.sumProjectPrice project)
                            ++ " PLN)"
                        )
                    ]
                ]
            , th
                [ colspan 2
                , class
                    ("project-deadline "
                        ++ (if project.is_deadline_rigid then
                                "rigid-deadline"

                            else
                                ""
                           )
                    )
                , title (U.ternary project.is_deadline_rigid "Sztywny" "Luźny" ++ " termin")
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
    , if U.isProjectExpanded project model.expandedProjects then
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
        , td
            [ class "task-name"
            , onClick (T.TaskRenameModalShow task)
            , title task.sent_note
            ]
            [ text task.name ]
        , td
            [ class "task-price"
            , onClick (T.TaskChangePriceModalShow task)
            ]
            [ text (U.formatPrice task.price ++ " PLN") ]
        , td [ class "task-worker-select-container" ] [ selectWorkerView model task ]
        , td [ class "task-status-select-container" ] [ selectTaskStatusView model task ]
        , td [ class "task-remove-button-container" ]
            [ button
                [ class "button-outline icon remove"
                , title "Usuń"
                , onClick (T.TaskRemoveRequest task)
                ]
                []
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
                [ class "add-task-button button-outline"
                , onClick (T.TaskCreateRequest project)
                ]
                [ i [ class "icon icon-plus" ]
                    []
                , span [] [ text "dodaj wyrób" ]
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
