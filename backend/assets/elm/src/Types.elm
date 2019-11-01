module Types exposing (..)

import Dict exposing (Dict)
import Http


type Msg
    = ToggleProjectExpand Project
    | GotProjects (Result Http.Error (List Project))


type alias ExpandedProjects =
    Dict Int Bool


type alias ModelValue =
    { projects : List Project
    , expandedProjects : ExpandedProjects
    }


type Model
    = Loading
    | Failure
    | Success ModelValue


type alias Worker =
    { id : Int
    , name : String
    }


type alias Task =
    { id : Int
    , name : String
    , status : String
    , worker : Worker
    }


type alias Client =
    { id : Int
    , name : String
    }


type alias Project =
    { id : Int
    , name : String
    , client : Client
    , tasks : List Task
    }
