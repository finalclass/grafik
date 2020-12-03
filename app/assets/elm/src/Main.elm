module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignRight, centerX, column, el, fill, height, link, map, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Page.Projects
import Page.Workers
import Route
import Session exposing (Session)
import Url
import Url.Parser as UrlParser



-- Model


type Model
    = Projects Page.Projects.Model
    | Workers Page.Workers.Model
    | NotFound Session
    | Redirect Session


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.urlToRoute url) (Redirect (Session.init navKey))


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



-- UPDATE


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | ProjectsMsg Page.Projects.Msg
    | WorkersMsg Page.Workers.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
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

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



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

                Redirect _ ->
                    el [] (text "")

                NotFound _ ->
                    el [] (text "Not found")
            ]
        ]



-- BOOT


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        , onUrlRequest = ClickLink
        , onUrlChange = ChangeUrl
        }
