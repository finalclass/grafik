module Tasks.Types exposing (..)

import Dict exposing (Dict)
import Http
import List
import Time


type Msg
    = CurrentProjectsReceived (Result Http.Error AllData)
    | GotZone Time.Zone
    | GotTime Time.Posix
    | Focus String
    | ProjectsMsg ProjectsMsgs
    | NoOp


type ProjectsMsgs
    = NewProject


type MainViewState
    = SuccessState
    | LoadingState
    | FailureState


type ProjectsType
    = CurrentProjects
    | ArchivedProjects


type alias Model =
    { mainViewState : MainViewState
    , projectsType : ProjectsType
    , projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    , visibleProjects : List Int
    , zone : Time.Zone
    , timeNow : Time.Posix
    , searchText : String
    , expandedProjects : ExpandedProjects
    }


type alias ExpandedProjects =
    Dict String Bool


type alias Worker =
    { id : Int
    , name : String
    }


type alias Task =
    { id : Int
    , project_id : Int
    , worker_id : Int
    , name : String
    , status : String
    , sent_note : String
    , price : Float
    }


type alias Client =
    { id : Int
    , name : String
    , invoice_name : String
    , invoice_street : String
    , invoice_postcode : String
    , invoice_city : String
    , invoice_nip : String
    , delivery_name : String
    , delivery_street : String
    , delivery_postcode : String
    , delivery_city : String
    , delivery_contact_person : String
    , phone_number : String
    , email : String
    }


type alias Project =
    { id : Int
    , client_id : Int
    , name : String
    , description : String
    , is_deadline_rigid : Bool
    , deadline : Time.Posix
    , invoice_number : String
    , price : Float
    , paid : Float
    , tasks : List Task
    , is_archived : Bool
    , start_at : Time.Posix
    }


type alias Status =
    { id : String
    , name : String
    }


type alias AllData =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    }
