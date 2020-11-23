module Clients exposing (emptyClient, selectOrCreateView, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Requests as R
import Types as T
import Utils as U


update : T.ClientsMsg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.ClientsSelectState state ->
            ( model |> updateEditedClient (\edCli -> { edCli | state = state }), Cmd.none )

        T.ClientsOnInputSearchText str ->
            ( model |> updateEditedClient (\edCli -> { edCli | searchText = str }), Cmd.none )

        T.ClientsClientSelected makeMsg clientId ->
            ( model |> updateEditedClient (\edCli -> { edCli | state = T.EditedClientSelected })
            , U.sendMsg (makeMsg clientId)
            )

        T.ClientsEdit client ->
            ( model
                |> updateEditedClient
                    (\edCli ->
                        { edCli
                            | state = T.EditedClientEdit
                            , data = client
                        }
                    )
            , Cmd.none
            )

        T.ClientsSaveRequest makeMsg ->
            ( model |> updateEditedClient (\edCli -> { edCli | saveErr = Nothing })
            , R.createOrUpdateClient model.editedClient.data makeMsg
            )

        T.ClientsCreated makeMsg result ->
            case result of
                Ok client ->
                    ( { model | clients = client :: model.clients }
                        |> updateEditedClient (\edCli -> { edCli | state = T.EditedClientSelected })
                    , U.sendMsg (makeMsg client.id)
                    )

                Err _ ->
                    ( model |> updateEditedClient (\edCli -> { edCli | saveErr = Just "Nie udało się zapisać klienta" }), Cmd.none )

        T.ClientsUpdated makeMsg result ->
            case result of
                Ok client ->
                    ( { model | clients = replaceClient client model.clients }
                        |> updateEditedClient (\edCli -> { edCli | state = T.EditedClientSelected })
                    , U.sendMsg (makeMsg client.id)
                    )

                Err _ ->
                    ( model |> updateEditedClient (\edCli -> { edCli | saveErr = Just "Nie udało się zapisać klienta" }), Cmd.none )

        T.ClientsCopyInvoiceToDeliveryData ->
            ( model
                |> updateEditedClientData
                    (\client ->
                        { client
                            | delivery_name = client.invoice_name
                            , delivery_street = client.invoice_street
                            , delivery_postcode = client.invoice_postcode
                            , delivery_city = client.invoice_city
                        }
                    )
            , Cmd.none
            )

        T.ClientsOnInputName str ->
            ( model |> updateEditedClientData (\c -> { c | name = str }), Cmd.none )

        T.ClientsOnInputInvoiceName str ->
            ( model |> updateEditedClientData (\c -> { c | invoice_name = str }), Cmd.none )

        T.ClientsOnInputInvoiceStreet str ->
            ( model |> updateEditedClientData (\c -> { c | invoice_street = str }), Cmd.none )

        T.ClientsOnInputInvoicePostcode str ->
            ( model |> updateEditedClientData (\c -> { c | invoice_postcode = str }), Cmd.none )

        T.ClientsOnInputInvoiceCity str ->
            ( model |> updateEditedClientData (\c -> { c | invoice_city = str }), Cmd.none )

        T.ClientsOnInputInvoiceNip str ->
            ( model |> updateEditedClientData (\c -> { c | invoice_nip = str }), Cmd.none )

        T.ClientsOnInputDeliveryName str ->
            ( model |> updateEditedClientData (\c -> { c | delivery_name = str }), Cmd.none )

        T.ClientsOnInputDeliveryStreet str ->
            ( model |> updateEditedClientData (\c -> { c | delivery_street = str }), Cmd.none )

        T.ClientsOnInputDeliveryPostcode str ->
            ( model |> updateEditedClientData (\c -> { c | delivery_postcode = str }), Cmd.none )

        T.ClientsOnInputDeliveryCity str ->
            ( model |> updateEditedClientData (\c -> { c | delivery_city = str }), Cmd.none )

        T.ClientsOnInputDeliveryContactPerson str ->
            ( model |> updateEditedClientData (\c -> { c | delivery_contact_person = str }), Cmd.none )

        T.ClientsOnInputPhoneNumber str ->
            ( model |> updateEditedClientData (\c -> { c | phone_number = str }), Cmd.none )

        T.ClientsOnInputEmail str ->
            ( model |> updateEditedClientData (\c -> { c | email = str }), Cmd.none )


replaceClient : T.Client -> List T.Client -> List T.Client
replaceClient client clients =
    List.map
        (\c ->
            if c.id == client.id then
                client

            else
                c
        )
        clients


updateEditedClient : (T.EditedClient -> T.EditedClient) -> T.Model -> T.Model
updateEditedClient func model =
    { model | editedClient = func model.editedClient }


updateEditedClientData : (T.Client -> T.Client) -> T.Model -> T.Model
updateEditedClientData func model =
    model |> updateEditedClient (\edCli -> { edCli | data = func edCli.data })


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
        (case U.findClient model clientId of
            Just client ->
                case model.editedClient.state of
                    T.EditedClientSelected ->
                        [ div [] [ clientView client ]
                        , newButtonView
                        , button
                            [ class "float-right button button-outline button-small"
                            , onClick (T.ClientsSelectState T.EditedClientSelect)
                            , title "Wybierz innego klienta"
                            ]
                            [ text "zmień" ]
                        , button
                            [ class "float-right button button-outline button-small"
                            , onClick (T.ClientsEdit client)
                            , title ("Edytuj " ++ client.name)
                            ]
                            [ text "edytuj" ]
                        ]

                    T.EditedClientSelect ->
                        [ selectView model makeMsg True ]

                    T.EditedClientEdit ->
                        [ newClientFormView model makeMsg ]

            Nothing ->
                case model.editedClient.state of
                    T.EditedClientSelected ->
                        [ selectView model makeMsg False ]

                    T.EditedClientSelect ->
                        [ selectView model makeMsg False ]

                    T.EditedClientEdit ->
                        [ newClientFormView model makeMsg ]
        )


newButtonView : Html T.ClientsMsg
newButtonView =
    button
        [ class "float-right button button-outline button-small"
        , onClick (T.ClientsSelectState T.EditedClientEdit)
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
            [ h4 [ class "float-left" ]
                [ text
                    (if data.id /= 0 then
                        "Edytuj klienta"

                     else
                        "Nowy klient"
                    )
                ]
            , cancelButtonView
            ]
        , inputView "Nazwa skrócona" data.name T.ClientsOnInputName
        , inputView "Faktura: nazwa" data.invoice_name T.ClientsOnInputInvoiceName
        , inputView "Faktura: ulica" data.invoice_street T.ClientsOnInputInvoiceStreet
        , inputView "Faktura: kod pocztowy" data.invoice_postcode T.ClientsOnInputInvoicePostcode
        , inputView "Faktura: miasto" data.invoice_city T.ClientsOnInputInvoiceCity
        , inputView "Faktura: NIP" data.invoice_nip T.ClientsOnInputInvoiceNip
        , button
            [ class "button-small"
            , onClick T.ClientsCopyInvoiceToDeliveryData
            , title "Skopiuj dane z faktury na adres dostawy"
            ]
            [ i [ class "icon icon-arrow-curved-down" ] []
            , text "ten sam adres dostawy"
            ]
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
        , button [ class "float-right button-small", onClick (T.ClientsSaveRequest selectClientMsg) ] [ text "Zapisz klienta" ]
        ]


inputView : String -> String -> (String -> T.ClientsMsg) -> Html T.ClientsMsg
inputView labelText inputValue msg =
    label []
        [ text labelText
        , input [ type_ "text", value inputValue, onInput msg ] []
        ]


selectView : T.Model -> (Int -> T.Msg) -> Bool -> Html T.ClientsMsg
selectView model makeMsg showCancel =
    div [ class "client-selection" ]
        [ div [ class "clearfix" ]
            [ div [ class "float-left" ]
                [ text "Wybierz klienta:"
                ]
            , newButtonView
            , if showCancel then
                cancelButtonView

              else
                text ""
            , input
                [ type_ "text"
                , placeholder "Szukaj..."
                , class "client-search-input"
                , onInput T.ClientsOnInputSearchText
                , value model.editedClient.searchText
                ]
                []
            ]
        , div [ class "clients-selection-container clearfix" ]
            (List.map
                (\client ->
                    div
                        [ class "client-button"
                        , onClick (T.ClientsClientSelected makeMsg client.id)
                        ]
                        [ clientView client ]
                )
                (filterClients model.editedClient.searchText model.clients)
            )
        ]


clientView : T.Client -> Html T.ClientsMsg
clientView client =
    table [ class "client-view" ]
        [ thead []
            [ tr []
                [ th [] [ text "Ogólne" ]
                , th [] [ text "Faktura" ]
                , th [] [ text "Dostawa" ]
                ]
            ]
        , tbody []
            [ tr []
                [ td []
                    [ div [ class "client-name" ] [ text client.name ]
                    , div [] [ text client.email ]
                    ]
                , td [ class "client-view-invoice" ]
                    [ div [] [ text client.invoice_name ]
                    , div [] [ text client.invoice_street ]
                    , div [] [ text (client.invoice_postcode ++ " " ++ client.invoice_city) ]
                    , div [] [ text ("NIP: " ++ client.invoice_nip) ]
                    ]
                , td [ class "client-view-delivery" ]
                    [ div [] [ text client.delivery_name ]
                    , div [] [ text client.delivery_street ]
                    , div [] [ text (client.delivery_postcode ++ " " ++ client.delivery_city) ]
                    , div [] [ text ("os. kontakt.: " ++ client.delivery_contact_person) ]
                    , div [] [ text ("tel.: " ++ client.phone_number) ]
                    ]
                ]
            ]
        ]


clientView2 : T.Client -> Html T.ClientsMsg
clientView2 client =
    div [ class "client-view" ]
        [ strong [] [ text (client.name ++ " ") ]
        , text
            (String.join " "
                [ if not (isStringEmpty client.phone_number) then
                    "tel: " ++ client.phone_number

                  else
                    ""
                , client.email
                , if
                    not (isStringEmpty client.invoice_name)
                        || not (isStringEmpty client.invoice_street)
                        || not (isStringEmpty client.invoice_postcode)
                        || not (isStringEmpty client.invoice_city)
                        || not (isStringEmpty client.invoice_nip)
                  then
                    "; FAKTURA: "
                        ++ String.join ", "
                            [ client.invoice_name
                            , client.invoice_street
                            , client.invoice_postcode ++ " " ++ client.invoice_city
                            ]
                        ++ " NIP: "
                        ++ client.invoice_nip

                  else
                    ""
                , if
                    not (isStringEmpty client.delivery_name)
                        || not (isStringEmpty client.delivery_street)
                        || not (isStringEmpty client.delivery_postcode)
                        || not (isStringEmpty client.delivery_city)
                        || not (isStringEmpty client.delivery_contact_person)
                  then
                    "; DOSTAWA:"
                        ++ String.join ", "
                            [ client.delivery_name
                            , client.delivery_street
                            , client.delivery_postcode ++ " " ++ client.delivery_city
                            , "os. kontaktowa: " ++ client.delivery_contact_person
                            ]

                  else
                    ""
                ]
            )
        ]


filterClients : String -> List T.Client -> List T.Client
filterClients searchText clients =
    List.filter
        (\c ->
            if String.length searchText == 0 then
                True

            else
                String.contains (String.toLower searchText) (String.toLower (clientToString c))
        )
        clients


clientToString : T.Client -> String
clientToString client =
    String.join ";"
        [ client.name
        , client.invoice_name
        , client.invoice_street
        , client.invoice_postcode
        , client.invoice_city
        , client.invoice_nip
        , client.delivery_name
        , client.delivery_street
        , client.delivery_postcode
        , client.delivery_city
        , client.delivery_contact_person
        , client.phone_number
        , client.email
        ]


isStringEmpty : String -> Bool
isStringEmpty str =
    String.length str == 0
