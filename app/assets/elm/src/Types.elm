module Types exposing (..)

import Dict exposing (Dict)
import Http


type Msg
    = ToggleProjectExpand Project
    | GotProjects (Result Http.Error (List Project))
    | TaskCreated Project (Result Http.Error Task)
    | TaskCreateRequest Project
    | TaskRemoveRequest Task
    | TaskRemoved Task (Result Http.Error Bool)


type alias ExpandedProjects =
    Dict String Bool


type MainViewState
    = MainViewShowProjects
    | MainViewShowLoading
    | MainViewShowFailure


type alias Model =
    { projects : List Project
    , expandedProjects : ExpandedProjects
    , mainViewState : MainViewState
    }


type alias Worker =
    { id : Int
    , name : String
    }


type alias Task =
    { id : Int
    , project_id : Int
    , name : String
    , status : String
    , worker : Maybe Worker
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
