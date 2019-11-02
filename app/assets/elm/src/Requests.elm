module Requests exposing (createNewTask, getAllProjects)

import Http
import Json.Decode as D
import Types


getAllProjects : Types.ModelValue -> Cmd Types.Msg
getAllProjects model =
    Http.get
        { url = "/api/projects"
        , expect = Http.expectJson (Types.GotProjects model) projectsDecoder
        }


createNewTask : Types.ModelValue -> Types.Project -> Cmd Types.Msg
createNewTask modelValue project =
    Http.post
        { url = "/api/projects/" ++ String.fromInt project.id ++ "/tasks"
        , body = Http.emptyBody
        , expect = Http.expectJson (Types.CreatedTask modelValue project) taskDecoder
        }


taskDecoder : D.Decoder Types.Task
taskDecoder =
    D.map4 Types.Task
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "status" D.string)
        (D.field "worker"
            (D.nullable
                (D.map2 Types.Worker
                    (D.field "id" D.int)
                    (D.field "name" D.string)
                )
            )
        )


projectsDecoder : D.Decoder (List Types.Project)
projectsDecoder =
    D.field "data"
        (D.list
            (D.map4 Types.Project
                (D.field "id" D.int)
                (D.field "name" D.string)
                (D.field "client"
                    (D.map2 Types.Client
                        (D.field "id" D.int)
                        (D.field "name" D.string)
                    )
                )
                (D.field "tasks"
                    (D.list taskDecoder)
                )
            )
        )
