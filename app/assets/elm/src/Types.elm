module Types exposing (..)

import Dict exposing (Dict)
import Http


type Msg
    = ToggleProjectExpand Project
    | AllDataReceived (Result Http.Error AllData)
    | TaskCreated Project (Result Http.Error Task)
    | TaskCreateRequest Project
    | TaskRemoveRequest Task
    | TaskRemoveConfirmed Task
    | TaskSetWorkerRequest Task String
    | TaskUpdated (Result Http.Error Task)
    | TaskRemoved Task (Result Http.Error Bool)
    | TaskRenameModalShow Task
    | TaskRenameRequest Task
    | TaskChangeStatusRequest Task String
    | ModalUpdatePromptValue String
    | ModalClose
    | SearchEnterText String


type alias ExpandedProjects =
    Dict String Bool


type MainViewState
    = SuccessState
    | LoadingState
    | FailureState


type Modal
    = ModalHidden
    | ModalConfirm String String Msg
    | ModalPrompt String Msg


type alias Model =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    , expandedProjects : ExpandedProjects
    , mainViewState : MainViewState
    , modal : Modal
    , modalPromptValue : String
    , searchText : String
    , visibleProjects : List Int
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
    , client_id : Int
    , name : String
    , client : Client
    , tasks : List Task
    }


type alias AllData =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    }


type alias Status =
    { id : String
    , name : String
    }
