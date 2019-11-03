module Types exposing (..)

import Dict exposing (Dict)
import Http


type Msg
    = ToggleProjectExpand Project
    | AllDataReceived (Result Http.Error AllData)
    | TaskCreated Project (Result Http.Error Task)
    | TaskCreateRequest Project
    | TaskRemoveRequest Task
    | TaskRemoved Task (Result Http.Error Bool)


type alias ExpandedProjects =
    Dict String Bool


type MainViewState
    = SuccessState
    | LoadingState
    | FailureState


type Modal
    = HiddenModal
    | ExampleModal


type alias Model =
    { projects : List Project
    , workers : List Worker
    , expandedProjects : ExpandedProjects
    , mainViewState : MainViewState
    , modal : Modal
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


type alias AllData =
    { projects : List Project
    , workers : List Worker
    }
