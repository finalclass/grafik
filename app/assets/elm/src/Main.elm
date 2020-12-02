module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (Element, alignRight, centerX, column, el, fill, height, link, map, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Page.Projects
import Route
import Session exposing (Session)
import Url
import Url.Parser as UrlParser



-- Model


type Model
    = Projects Page.Projects.Model
    | NotFound Session
    | Redirect Session


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.urlToRoute url) Redirect navKey


toSession model =
    case model of
        NotFound session ->
            session

        Redirect session ->
            session

        Projects projectsModel ->
            Page.Projects.toSession projectsModel


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
            ( subModel, Cmd.map ProjectsMsg cmd )

        Route.NotFoundRoute ->
            ( NotFound session, Cmd.none )



-- UPDATE


type Msg
    = ClickLink Browser.UrlRequest
    | ChangeUrl Url.Url
    | ProjectsMsg Page.Projects.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ChangeUrl url ->
            changeRouteTo (Route.urlToRoute url) model

        ProjectsMsg subMsg ->
            let
                ( projectsModel, projectsCmd ) =
                    Page.Projects.update subMsg model
            in
            ( projectsModel, Cmd.map ProjectsMsg projectsCmd )



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
                Projects _ ->
                    map ProjectsMsg (Page.Projects.view model)

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
