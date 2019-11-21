module Clients exposing (emptyClient, findClient, selectOrCreateView, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Requests as R
import Task
import Types as T


sendMsg : T.Msg -> Cmd T.Msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


update : T.ClientsMsg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.ClientsSelectState state ->
            ( updateEditedClient model (\edCli -> { edCli | state = state }), Cmd.none )

        T.ClientsClientSelected makeMsg clientId ->
            ( updateEditedClient model (\edCli -> { edCli | state = T.EditedClientSelected })
            , sendMsg (makeMsg clientId)
            )

        T.ClientsSaveRequest makeMsg ->
            ( updateEditedClient model (\edCli -> { edCli | saveErr = Nothing })
            , R.createNewClient model.editedClient.data makeMsg
            )

        T.ClientsCreated makeMsg result ->
            case result of
                Ok client ->
                    let
                        newModel =
                            updateEditedClient model (\edCli -> { edCli | state = T.EditedClientSelected })
                    in
                    ( { newModel | clients = client :: model.clients }
                    , sendMsg (makeMsg client.id)
                    )

                Err _ ->
                    ( updateEditedClient model (\edCli -> { edCli | saveErr = Just "Nie udało się zapisać klienta" }), Cmd.none )

        T.ClientsOnInputName str ->
            ( updateEditedClientData model (\c -> { c | name = str }), Cmd.none )

        T.ClientsOnInputInvoiceName str ->
            ( updateEditedClientData model (\c -> { c | invoice_name = str }), Cmd.none )

        T.ClientsOnInputInvoiceStreet str ->
            ( updateEditedClientData model (\c -> { c | invoice_street = str }), Cmd.none )

        T.ClientsOnInputInvoicePostcode str ->
            ( updateEditedClientData model (\c -> { c | invoice_postcode = str }), Cmd.none )

        T.ClientsOnInputInvoiceCity str ->
            ( updateEditedClientData model (\c -> { c | invoice_city = str }), Cmd.none )

        T.ClientsOnInputInvoiceNip str ->
            ( updateEditedClientData model (\c -> { c | invoice_nip = str }), Cmd.none )

        T.ClientsOnInputDeliveryName str ->
            ( updateEditedClientData model (\c -> { c | delivery_name = str }), Cmd.none )

        T.ClientsOnInputDeliveryStreet str ->
            ( updateEditedClientData model (\c -> { c | delivery_street = str }), Cmd.none )

        T.ClientsOnInputDeliveryPostcode str ->
            ( updateEditedClientData model (\c -> { c | delivery_postcode = str }), Cmd.none )

        T.ClientsOnInputDeliveryCity str ->
            ( updateEditedClientData model (\c -> { c | delivery_city = str }), Cmd.none )

        T.ClientsOnInputDeliveryContactPerson str ->
            ( updateEditedClientData model (\c -> { c | delivery_contact_person = str }), Cmd.none )

        T.ClientsOnInputPhoneNumber str ->
            ( updateEditedClientData model (\c -> { c | phone_number = str }), Cmd.none )

        T.ClientsOnInputEmail str ->
            ( updateEditedClientData model (\c -> { c | email = str }), Cmd.none )


updateEditedClient : T.Model -> (T.EditedClient -> T.EditedClient) -> T.Model
updateEditedClient model func =
    { model | editedClient = func model.editedClient }


updateEditedClientData : T.Model -> (T.Client -> T.Client) -> T.Model
updateEditedClientData model func =
    updateEditedClient model (\edCli -> { edCli | data = func edCli.data })


emptyClient : T.Client
emptyClient =
    { id = 0
    , name = ""
    , invoice_name = ""
    , invoice_street = ""
    , invoice_postcode = ""
    , invoice_city = ""
    , invoice_nip = ""
    , delivery_name = ""
    , delivery_street = ""
    , delivery_postcode = ""
    , delivery_city = ""
    , delivery_contact_person = ""
    , phone_number = ""
    , email = ""
    }


selectOrCreateView : T.Model -> Int -> (Int -> T.Msg) -> Html T.ClientsMsg
selectOrCreateView model clientId makeMsg =
    div [ class "client-select-or-create" ]
        (case findClient model clientId of
            Just client ->
                case model.editedClient.state of
                    T.EditedClientSelected ->
                        [ text client.name
                        , button
                            [ class "float-right button button-outline button-small"
                            , onClick (T.ClientsSelectState T.EditedClientSelect)
                            ]
                            [ text "zmień" ]
                        , newButtonView
                        ]

                    T.EditedClientSelect ->
                        [ selectView model makeMsg ]

                    T.EditedClientNew ->
                        [ newClientFormView model makeMsg ]

            Nothing ->
                [ selectView model makeMsg ]
        )


newButtonView : Html T.ClientsMsg
newButtonView =
    button
        [ class "float-right button button-outline button-small"
        , onClick (T.ClientsSelectState T.EditedClientNew)
        ]
        [ text "nowy" ]


cancelButtonView : Html T.ClientsMsg
cancelButtonView =
    button
        [ class "float-right button-outline button-small"
        , onClick (T.ClientsSelectState T.EditedClientSelected)
        ]
        [ text "anuluj" ]


newClientFormView : T.Model -> (Int -> T.Msg) -> Html T.ClientsMsg
newClientFormView model selectClientMsg =
    let
        data =
            model.editedClient.data
    in
    div []
        [ div [ class "clearfix" ]
            [ h4 [ class "float-left" ] [ text "Nowy klient" ]
            , cancelButtonView
            ]
        , inputView "Nazwa skrócona" data.name T.ClientsOnInputName
        , inputView "Faktura: nazwa" data.invoice_name T.ClientsOnInputInvoiceName
        , inputView "Faktura: ulica" data.invoice_street T.ClientsOnInputInvoiceStreet
        , inputView "Faktura: kod pocztowy" data.invoice_postcode T.ClientsOnInputInvoicePostcode
        , inputView "Faktura: miasto" data.invoice_city T.ClientsOnInputInvoiceCity
        , inputView "Faktura: NIP" data.invoice_nip T.ClientsOnInputInvoiceNip
        , inputView "Dostawa: nazwa" data.delivery_name T.ClientsOnInputDeliveryName
        , inputView "Dostawa: ulica" data.delivery_street T.ClientsOnInputDeliveryStreet
        , inputView "Dostawa: kod pocztowy" data.delivery_postcode T.ClientsOnInputDeliveryPostcode
        , inputView "Dostawa: miasto" data.delivery_city T.ClientsOnInputDeliveryCity
        , inputView "Dostawa: osoba kontaktowa" data.delivery_contact_person T.ClientsOnInputDeliveryContactPerson
        , inputView "Dostawa: numer telefonu" data.phone_number T.ClientsOnInputPhoneNumber
        , inputView "Dostawa: email" data.email T.ClientsOnInputEmail
        , case model.editedClient.saveErr of
            Just err ->
                text err

            Nothing ->
                text ""
        , button [ class "float-right button-small", onClick (T.ClientsSaveRequest selectClientMsg) ] [ text "Utwórz klienta" ]
        ]


inputView : String -> String -> (String -> T.ClientsMsg) -> Html T.ClientsMsg
inputView labelText inputValue msg =
    label []
        [ text labelText
        , input [ type_ "text", value inputValue, onInput msg ] []
        ]


selectView : T.Model -> (Int -> T.Msg) -> Html T.ClientsMsg
selectView model makeMsg =
    div [ class "client-selection" ]
        [ div [ class "clearfix" ]
            [ div [ class "float-left" ] [ text "Wybierz:" ]
            , cancelButtonView
            , newButtonView
            ]
        , div [ class "clients-selection-container clearfix" ]
            (List.map
                (\client ->
                    button
                        [ class "client-button button-small"
                        , onClick (T.ClientsClientSelected makeMsg client.id)
                        ]
                        [ text client.name ]
                )
                model.clients
            )
        ]


findClient : T.Model -> Int -> Maybe T.Client
findClient model clientId =
    List.filter (\c -> c.id == clientId) model.clients
        |> List.head
