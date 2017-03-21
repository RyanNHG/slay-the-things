module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utilities exposing (getCmd)
import Context exposing (Context)
import MainMenu
import HeroCreate
import CombatView


type alias Model =
    { context : Context
    , pageModels : PageModels
    }


type Msg
    = ContextMsg Context.Msg
    | MainMenuMsg MainMenu.Msg
    | HeroCreateMsg HeroCreate.Msg
    | CombatViewMsg CombatView.Msg


type alias PageModels =
    { mainMenu : MainMenu.Model
    , heroCreate : HeroCreate.Model
    , combatView : CombatView.Model
    }



-- | MapView MapViewModel
-- | RoadView RoadViewModel
-- | CombatView CombatViewModel


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model
                (initContext)
                (initPageModels initContext)
    in
        model ! []


initContext : Context
initContext =
    Context
        Nothing
        []
        Context.MainMenu


initPageModels : Context -> PageModels
initPageModels context =
    PageModels
        (MainMenu.init context)
        (HeroCreate.init context)
        (CombatView.init context)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context =
            model.context
    in
        case msg of
            ContextMsg msg ->
                case msg of
                    Context.GotoPage page ->
                        let
                            newContext =
                                { context | page = page }
                        in
                            { model | context = newContext } ! []

                    Context.InitPage page ->
                        let
                            newContext =
                                { context | page = page }
                        in
                            { model
                                | context = newContext
                                , pageModels = initPageModel page context model.pageModels
                            }
                                ! []

                    Context.AddHero hero ->
                        let
                            newContext =
                                { context
                                    | heroes = context.heroes ++ [ hero ]
                                    , hero = Just hero
                                }
                        in
                            { model | context = newContext } ! [ getCmd <| ContextMsg <| Context.InitPage Context.MainMenu ]

                    Context.PlayAs hero ->
                        let
                            newContext =
                                { context
                                    | hero = Just hero
                                    , page = Context.CombatView
                                }
                        in
                            { model | context = newContext } ! [ getCmd <| ContextMsg <| Context.InitPage Context.CombatView ]

            MainMenuMsg msg ->
                localUpdate
                    (MainMenu.update msg model.pageModels.mainMenu)
                    MainMenuMsg
                    updateMainMenuPageModel
                    model

            HeroCreateMsg msg ->
                localUpdate
                    (HeroCreate.update msg model.pageModels.heroCreate)
                    HeroCreateMsg
                    updateHeroCreatePageModel
                    model

            CombatViewMsg msg ->
                localUpdate
                    (CombatView.update msg model.pageModels.combatView)
                    CombatViewMsg
                    updateCombatViewPageModel
                    model


localUpdate : ( aModel, Cmd aMsg, Cmd Context.Msg ) -> (aMsg -> Msg) -> (aModel -> PageModels -> PageModels) -> Model -> ( Model, Cmd Msg )
localUpdate ( localModel, localMsg, contextMsg ) msgFunc pageModelsUpdater model =
    let
        pageModels =
            pageModelsUpdater localModel model.pageModels
    in
        { model | pageModels = pageModels }
            ! [ Cmd.map msgFunc localMsg
              , Cmd.map ContextMsg contextMsg
              ]


updateMainMenuPageModel : MainMenu.Model -> PageModels -> PageModels
updateMainMenuPageModel model pageModels =
    { pageModels | mainMenu = model }


updateHeroCreatePageModel : HeroCreate.Model -> PageModels -> PageModels
updateHeroCreatePageModel model pageModels =
    { pageModels | heroCreate = model }


updateCombatViewPageModel : CombatView.Model -> PageModels -> PageModels
updateCombatViewPageModel model pageModels =
    { pageModels | combatView = model }


initPageModel : Context.Page -> Context -> PageModels -> PageModels
initPageModel page context =
    case page of
        Context.MainMenu ->
            updateMainMenuPageModel (MainMenu.init context)

        Context.HeroCreate ->
            updateHeroCreatePageModel (HeroCreate.init context)

        Context.CombatView ->
            updateCombatViewPageModel (CombatView.init context)


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewPage model
        ]


viewPage : Model -> Html Msg
viewPage model =
    let
        models =
            model.pageModels
    in
        case model.context.page of
            Context.MainMenu ->
                Html.map MainMenuMsg (MainMenu.view models.mainMenu)

            Context.HeroCreate ->
                Html.map HeroCreateMsg (HeroCreate.view models.heroCreate)

            Context.CombatView ->
                Html.map CombatViewMsg (CombatView.view models.combatView)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
