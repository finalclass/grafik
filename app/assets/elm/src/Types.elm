module Types exposing (..)

import Dict exposing (Dict)
import Http
import Time


type ClientsMsg
    = ClientsSelectState EditedClientState
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
    | ClientsOnInputEmail String
    | ClientsSave (Int -> Msg)


type ProjectsMsg
    = ProjectsStartEdit Project
    | ProjectsSaveRequest Project
    | ProjectsOnInputName String
    | ProjectsOnInputIsDeadlineRigid String
    | ProjectsOnInputDeadlineString String
    | ProjectsOnInputInvoiceNumber String
    | ProjectsOnInputPrice String
    | ProjectsOnInputPaid String
    | ProjectsOnClientIdSelected Int
    | ProjectsEditClient ClientsMsg


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
    }


type EditedClientState
    = EditedClientSelect
    | EditedClientSelected
    | EditedClientNew


type alias EditedClient =
    { data : Client
    , state : EditedClientState
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
