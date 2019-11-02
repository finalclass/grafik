module Requests exposing (getAllProjects)

import Http
import Json.Decode exposing (..)
import Types


getAllProjects : Cmd Types.Msg
getAllProjects =
    Http.get
        { url = "/api/projects"
        , expect = Http.expectJson Types.GotProjects projectsDecoder
        }


projectsDecoder : Decoder (List Types.Project)
projectsDecoder =
    field "data"
        (list
            (map4 Types.Project
                (field "id" int)
                (field "name" string)
                (field "client"
                    (map2 Types.Client
                        (field "id" int)
                        (field "name" string)
                    )
                )
                (field "tasks"
                    (list
                        (map4 Types.Task
                            (field "id" int)
                            (field "name" string)
                            (field "status" string)
                            (field "worker"
                                (map2 Types.Worker
                                    (field "id" int)
                                    (field "name" string)
                                )
                            )
                        )
                    )
                )
            )
        )
