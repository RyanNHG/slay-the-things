module MainMenu exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (getCmd, unpartition)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias MenuButton =
    { label : String
    , onClick : Msg
    }


type alias Model =
    { title : String
    , buttons : List MenuButton
    }


type Msg
    = CreateHeroClicked
    | PlayAs Hero


init : Context -> Model
init context =
    Model
        "Slay the Things!"
        (initButtons context)


initButtons : Context -> List MenuButton
initButtons context =
    let
        heroButtons =
            context.heroes
                |> (List.partition (isActiveHero context.hero))
                |> Debug.log "partition"
                |> unpartition
                |> Debug.log "unpartition"
                |> (List.map getButtonForHero)
                |> Debug.log "map"
    in
        initialButtons ++ heroButtons


isActiveHero : Maybe Hero -> Hero -> Bool
isActiveHero maybeActiveHero hero =
    case maybeActiveHero of
        Just activeHero ->
            activeHero == hero

        Nothing ->
            False


getButtonForHero : Hero -> MenuButton
getButtonForHero hero =
    MenuButton
        ("Play as " ++ hero.name)
        (PlayAs hero)


initialButtons : List MenuButton
initialButtons =
    [ (MenuButton "Create your hero!" CreateHeroClicked)
    ]


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        CreateHeroClicked ->
            ( model
            , Cmd.none
            , getCmd <| Context.InitPage Context.HeroCreate
            )

        PlayAs hero ->
            ( model
            , Cmd.none
            , getCmd <| Context.PlayAs hero
            )


view : Model -> Html Msg
view model =
    div [ class "main-menu container row" ]
        [ div [ class "column" ] [ viewTitle model ]
        , div [ class "column align-start" ] [ viewMenuButtons model ]
        ]


viewTitle : Model -> Html Msg
viewTitle model =
    div [ class "title-section" ]
        [ h2 [] [ text model.title ]
        ]


viewMenuButtons : Model -> Html Msg
viewMenuButtons model =
    div [ class "action-section" ]
        (List.map viewMenuButton model.buttons)


viewMenuButton : MenuButton -> Html Msg
viewMenuButton menuButton =
    button [ class "button", onClick menuButton.onClick ]
        [ text menuButton.label ]