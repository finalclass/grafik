port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignRight, centerX, column, el, fill, height, link, map, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Json.Decode as D
import Json.Encode as E
import Page.Projects
import Page.Workers
import Route
import Session exposing (Session)
import Task
import Time
import Tuple
import Url
import Url.Parser as UrlParser



-- PORTS


port localStoragePutItem : E.Value -> Cmd msg


port localStorageGetItem : E.Value -> Cmd msg


port localStorage : (E.Value -> msg) -> Sub msg



-- MODEL


type Model
    = Projects Page.Projects.Model
    | Workers Page.Workers.Model
    | NotFound Session
    | Redirect Session
    | Init Url.Url Nav.Key Time.Zone


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( Init url navKey Time.utc, Task.perform GotZone Time.here )


changeRouteTo : Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        session =
            toSession model
    in
    case route of
        Route.ProjectsRoute ->
            let
                ( subModel, cmd ) =
                    Page.Projects.init session
            in
            ( Projects subModel, Cmd.map ProjectsMsg cmd )

        Route.WorkersRoute ->
            let
                ( subModel, cmd ) =
                    Page.Workers.init session
            in
            ( Workers subModel, Cmd.map WorkersMsg cmd )

        Route.NotFoundRoute ->
            ( NotFound session, Cmd.none )


toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session

        Redirect session ->
            session

        Projects projectsModel ->
            Page.Projects.toSession projectsModel

        Workers workersModel ->
            Page.Workers.toSession workersModel

        Init _ navKey _ ->
            Session.empty navKey


updateSession : Model -> Session -> Model
updateSession model session =
    case model of
        NotFound _ ->
            NotFound session

        Redirect _ ->
            Redirect session

        Projects projectsModel ->
            Projects (Page.Projects.updateSession projectsModel session)

        Workers workersModel ->
            Workers (Page.Workers.updateSession workersModel session)

        Init a b c ->
            -- session is not ready yet
            Init a b c


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | ProjectsMsg Page.Projects.Msg
    | WorkersMsg Page.Workers.Msg
    | GotZone Time.Zone
    | GotTime Time.Posix
    | LocalStorageUpdate E.Value
    | LocalStorageGetRequest String
    | LocalStoragePutRequest String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotZone zone, Init url navKey _ ) ->
            ( Init url navKey zone, Task.perform GotTime Time.now )

        ( GotTime time, Init url navKey zone ) ->
            changeRouteTo (Route.urlToRoute url) (Redirect (Session.init navKey zone time))

        ( ClickLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (toSession model).navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ( ChangeUrl url, _ ) ->
            changeRouteTo (Route.urlToRoute url) model

        ( ProjectsMsg subMsg, Projects projectsModel ) ->
            let
                ( newProjectsModel, projectsCmd ) =
                    Page.Projects.update subMsg projectsModel
            in
            ( Projects newProjectsModel, Cmd.map ProjectsMsg projectsCmd )

        ( LocalStorageUpdate str, _ ) ->
            case D.decodeValue decodeLocalStorage str of
                Ok item ->
                    ( item
                        |> Session.saveToLocalStorage (toSession model)
                        |> updateSession model
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        ( LocalStorageGetRequest key, _ ) ->
            ( model, localStorageGetItem (encodeLocalStorage { key = key, value = "" }) )

        ( LocalStoragePutRequest key value, _ ) ->
            ( model, localStoragePutItem (encodeLocalStorage { key = key, value = value }) )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


type alias LocalStorageItem =
    { key : String, value : String }


encodeLocalStorage : LocalStorageItem -> E.Value
encodeLocalStorage item =
    E.object
        [ ( "key", E.string item.key )
        , ( "value", E.string item.value )
        ]


decodeLocalStorage : D.Decoder LocalStorageItem
decodeLocalStorage =
    D.map2 LocalStorageItem
        (D.field "key" D.string)
        (D.field "value" D.string)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Grafik"
    , body = [ Element.layout [] (layout model) ]
    }


layout : Model -> Element Msg
layout model =
    let
        topBarLinkColor =
            Font.color (rgb255 0 105 217)
    in
    column [ width fill ]
        [ row [ Background.tiledX "/images/header.jpg", width fill, height (px 57) ]
            [ row [ width (px 1120), centerX ]
                [ link
                    [ Font.color (rgb255 221 27 22), Font.heavy, Font.italic ]
                    { url = "/", label = text "Grafik" }
                , row [ spacing 16, alignRight ]
                    [ link [ topBarLinkColor ] { url = "/", label = text "Zamówienia" }
                    , link [ topBarLinkColor ] { url = "/workers", label = text "Pracownicy" }
                    ]
                ]
            ]
        , row [ width (px 1120), centerX ]
            [ case model of
                Projects projectsModel ->
                    map ProjectsMsg (Page.Projects.view projectsModel)

                Workers workersModel ->
                    map WorkersMsg (Page.Workers.view workersModel)

                NotFound _ ->
                    el [] (text "Not found")

                _ ->
                    el [] (text "")
            ]
        ]



-- BOOT


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = \_ -> localStorage LocalStorageUpdate
        , view = view
        , onUrlRequest = ClickLink
        , onUrlChange = ChangeUrl
        }
