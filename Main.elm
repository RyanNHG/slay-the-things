module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Context exposing (Context)
import MainMenu
import HeroCreate


type alias Model =
    { context : Context
    , pageModels : PageModels
    }


type Msg
    = ContextMsg Context.Msg
    | MainMenuMsg MainMenu.Msg
    | HeroCreateMsg HeroCreate.Msg


type alias PageModels =
    { mainMenu : MainMenu.Model
    , heroCreate : HeroCreate.Model
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


initPageModel : Context.Page -> Context -> PageModels -> PageModels
initPageModel page context =
    case page of
        Context.MainMenu ->
            updateMainMenuPageModel (MainMenu.init context)

        Context.HeroCreate ->
            updateHeroCreatePageModel (HeroCreate.init context)


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
