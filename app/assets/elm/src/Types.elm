module Types exposing (..)

import Dict exposing (Dict)
import Http
import Time


type ProjectsMsg
    = ProjectsStartEdit Project
    | ProjectsSaveRequest Project
    | ProjectsOnInputName String
    | ProjectsOnInputIsDeadlineRigid String
    | ProjectsOnInputDeadlineString String
    | ProjectsOnInputInvoiceNumber String
    | ProjectsOnInputPrice String
    | ProjectsOnInputPaid String


type Msg
    = ToggleProjectExpand Project
    | AllDataReceived (Result Http.Error AllData)
    | TaskCreated Project (Result Http.Error Task)
    | TaskCreateRequest Project
    | TaskCreateSave Project
    | TaskRemoveRequest Task
    | TaskRemoveConfirmed Task
    | TaskSetWorkerRequest Task String
    | TaskUpdated (Result Http.Error Task)
    | TaskRemoved Task (Result Http.Error Bool)
    | TaskRenameModalShow Task
    | TaskRenameRequest Task
    | TaskChangeStatusRequest Task String
    | ModalUpdatePromptValue String
    | ProjectsAction ProjectsMsg
    | ModalClose
    | SearchEnterText String
    | NoOp
    | Focus String
    | GotZone Time.Zone


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
    | ModalEditProject Project


type alias Model =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    , zone : Time.Zone
    , expandedProjects : ExpandedProjects
    , editedProjectDeadlineString : String
    , editedProjectDeadlineError : String
    , mainViewState : MainViewState
    , modal : Modal
    , modalPromptValue : String
    , searchText : String
    , visibleProjects : List Int
    , editedProject : Project
    }


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
    , sent_at : Time.Posix
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
    , is_deadline_rigid : Bool
    , deadline : Time.Posix
    , invoice_number : String
    , price : Float
    , paid : Float
    , tasks : List Task
    }


type alias AllData =
    { projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    }


type alias Status =
    { id : String
    , name : String
    }
