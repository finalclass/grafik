module Types exposing (..)

import Dict exposing (Dict)
import Http
import Time


type ClientsMsg
    = ClientsSelectState EditedClientState
    | ClientsEdit Client
    | ClientsClientSelected (Int -> Msg) Int
    | ClientsOnInputName String
    | ClientsOnInputInvoiceName String
    | ClientsOnInputInvoiceStreet String
    | ClientsOnInputInvoicePostcode String
    | ClientsOnInputInvoiceCity String
    | ClientsOnInputInvoiceNip String
    | ClientsOnInputDeliveryName String
    | ClientsOnInputDeliveryStreet String
    | ClientsOnInputDeliveryPostcode String
    | ClientsOnInputDeliveryCity String
    | ClientsOnInputDeliveryContactPerson String
    | ClientsOnInputPhoneNumber String
    | ClientsOnInputSearchText String
    | ClientsOnInputEmail String
    | ClientsSaveRequest (Int -> Msg)
    | ClientsCreated (Int -> Msg) (Result Http.Error Client)
    | ClientsUpdated (Int -> Msg) (Result Http.Error Client)


type ProjectsMsg
    = ProjectsStartEdit Project
    | ProjectsNewProject
    | ProjectsSaveRequest
    | ProjectsOnInputName String
    | ProjectsOnInputDescription String
    | ProjectsOnInputIsDeadlineRigid String
    | ProjectsOnInputDeadlineString String
    | ProjectsOnInputInvoiceNumber String
    | ProjectsOnInputPrice String
    | ProjectsOnInputPaid String
    | ProjectsOnClientIdSelected Int
    | ProjectsOnInputIsArchived String
    | ProjectsOnInputStartAtString String
    | ProjectsEditClient ClientsMsg
    | ProjectsCreated (Result Http.Error Project)
    | ProjectsUpdated (Result Http.Error Project)


type Msg
    = ToggleProjectExpand Project
    | AllDataReceived ProjectsType (Result Http.Error AllData)
    | ToggleProjectsType
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
    | GotTime Time.Posix


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
    | ModalEditProject


type ProjectsType
    = ArchivedProjects
    | CurrentProjects


type alias Model =
    { projectsType : ProjectsType
    , projects : List Project
    , workers : List Worker
    , statuses : List Status
    , clients : List Client
    , zone : Time.Zone
    , timeNow : Time.Posix
    , expandedProjects : ExpandedProjects
    , editedProject : EditedProject
    , editedClient : EditedClient
    , mainViewState : MainViewState
    , modal : Modal
    , modalPromptValue : String
    , searchText : String
    , visibleProjects : List Int
    }


type alias EditedProject =
    { data : Project
    , deadlineString : String
    , deadlineErr : Maybe String
    , startAtString : String
    , startAtErr : Maybe String
    , saveErr : Maybe String
    }


type EditedClientState
    = EditedClientSelect
    | EditedClientSelected
    | EditedClientEdit


type alias EditedClient =
    { data : Client
    , state : EditedClientState
    , saveErr : Maybe String
    , searchText : String
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
