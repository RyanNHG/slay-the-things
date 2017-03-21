module HeroCreate exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (getCmd, just)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type MainClass
    = AlmostMelee (Maybe MeleeSubclass)
    | AlmostRanged (Maybe RangedSubclass)
    | AlmostMagic (Maybe MagicSubclass)


type CreateStep
    = HasNothingSelected
    | HasMainClassSelected
    | HasSubclassSelected


type alias Model =
    { heroClass : Maybe MainClass
    , heroName : String
    }


type Msg
    = MainClassSelected MainClass
    | MeleeSubclassSelected MeleeSubclass
    | RangedSubclassSelected RangedSubclass
    | MagicSubclassSelected MagicSubclass
    | MainClassReset
    | SubclassReset
    | NameChanged String
    | CreateHero
    | GoToMainMenu


init : Context -> Model
init context =
    Model
        Nothing
        ""


initialLevel : Int
initialLevel =
    1


initialAttributes : HeroClass -> HeroAttributes
initialAttributes class =
    case class of
        Melee subclass ->
            case subclass of
                Knight ->
                    HeroAttributes 4 4 4 4

                Rogue ->
                    HeroAttributes 4 4 4 4

        Ranged subclass ->
            case subclass of
                Ranger ->
                    HeroAttributes 4 4 4 4

                Axethrower ->
                    HeroAttributes 4 4 4 4

        Magic subclass ->
            case subclass of
                Wizard ->
                    HeroAttributes 4 4 4 4

                Healer ->
                    HeroAttributes 4 4 4 4


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        GoToMainMenu ->
            ( model, Cmd.none, getCmd <| Context.GotoPage Context.MainMenu )

        MainClassSelected mainclass ->
            just { model | heroClass = Just mainclass }

        MeleeSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostMelee <| Just subclass }

        RangedSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostRanged <| Just subclass }

        MagicSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostMagic <| Just subclass }

        MainClassReset ->
            just { model | heroClass = Nothing }

        SubclassReset ->
            let
                heroMainClass =
                    getEmptyMainClass model.heroClass
            in
                just { model | heroClass = Just <| heroMainClass }

        NameChanged name ->
            just { model | heroName = name }

        CreateHero ->
            case getHero model of
                Just hero ->
                    ( model
                    , Cmd.none
                    , getCmd <| Context.AddHero hero
                    )

                Nothing ->
                    let
                        _ =
                            Debug.log "Hero could not be created..."
                    in
                        just model


getHero : Model -> Maybe Hero
getHero model =
    let
        maybeHeroClass =
            getHeroClass model.heroClass
    in
        if String.length model.heroName == 0 then
            Nothing
        else
            case maybeHeroClass of
                Just heroClass ->
                    Just
                        (Hero
                            model.heroName
                            heroClass
                            initialLevel
                            (initialAttributes heroClass)
                        )

                Nothing ->
                    Nothing


getHeroClass : Maybe MainClass -> Maybe HeroClass
getHeroClass maybeMainClass =
    case maybeMainClass of
        Nothing ->
            Nothing

        Just class ->
            case class of
                AlmostMelee subclass ->
                    case subclass of
                        Just subclass ->
                            Just <| Melee subclass

                        Nothing ->
                            Nothing

                AlmostRanged subclass ->
                    case subclass of
                        Just subclass ->
                            Just <| Ranged subclass

                        Nothing ->
                            Nothing

                AlmostMagic subclass ->
                    case subclass of
                        Just subclass ->
                            Just <| Magic subclass

                        Nothing ->
                            Nothing


getEmptyMainClass : Maybe MainClass -> MainClass
getEmptyMainClass maybeAlmostHero =
    case maybeAlmostHero of
        Just almostHero ->
            case almostHero of
                AlmostMelee _ ->
                    AlmostMelee Nothing

                AlmostRanged _ ->
                    AlmostRanged Nothing

                AlmostMagic _ ->
                    AlmostMagic Nothing

        Nothing ->
            let
                _ =
                    Debug.log <|
                        "HeroCreate: 'getEmptyMainClass' was designed to only be used to reset subclasses."
                            ++ " No subclass was found, so the 'AlmostMelee' default is being used."
                            ++ "Maybe maybe I should not have nested my maybes..."
            in
                AlmostMelee Nothing


getCreateStep : Model -> CreateStep
getCreateStep model =
    case model.heroClass of
        Nothing ->
            HasNothingSelected

        Just mainclass ->
            case mainclass of
                AlmostMelee thing ->
                    case thing of
                        Just _ ->
                            HasSubclassSelected

                        Nothing ->
                            HasMainClassSelected

                AlmostRanged thing ->
                    case thing of
                        Just _ ->
                            HasSubclassSelected

                        Nothing ->
                            HasMainClassSelected

                AlmostMagic thing ->
                    case thing of
                        Just _ ->
                            HasSubclassSelected

                        Nothing ->
                            HasMainClassSelected


view : Model -> Html Msg
view model =
    div [ class "hero-create" ]
        [ viewNavbar model
        , viewOptions model
        , viewFooter model
        ]


viewNavbar : Model -> Html Msg
viewNavbar model =
    nav [ class "navbar" ]
        [ viewBackButton model
        , viewNavbarLabel model
        ]


viewBackButton : Model -> Html Msg
viewBackButton model =
    let
        onClickMsg =
            case getCreateStep model of
                HasNothingSelected ->
                    GoToMainMenu

                HasMainClassSelected ->
                    MainClassReset

                HasSubclassSelected ->
                    SubclassReset
    in
        button [ class "button back-button", onClick onClickMsg ]
            [ i [ class "fa fa-arrow-left" ] [] ]


viewNavbarLabel : Model -> Html Msg
viewNavbarLabel model =
    div [ class "navbar-label" ]
        [ h4 []
            [ text <|
                case getCreateStep model of
                    HasNothingSelected ->
                        "What's your style?"

                    HasMainClassSelected ->
                        "What's your class?"

                    HasSubclassSelected ->
                        "What's your name?"
            ]
        ]


viewOptions : Model -> Html Msg
viewOptions model =
    div [ class "options-section" ]
        [ case getCreateStep model of
            HasNothingSelected ->
                viewMainClassOptions model

            HasMainClassSelected ->
                viewSubclassOptions model

            HasSubclassSelected ->
                viewNameOptions model
        ]


type alias ClassOption =
    { label : String
    , msg : Msg
    }


mainClassOptions : List ClassOption
mainClassOptions =
    [ ClassOption "Melee" (MainClassSelected <| AlmostMelee Nothing)
    , ClassOption "Ranged" (MainClassSelected <| AlmostRanged Nothing)
    , ClassOption "Magic" (MainClassSelected <| AlmostMagic Nothing)
    ]


meleeSubclassOptions : List ClassOption
meleeSubclassOptions =
    [ ClassOption "Knight" (MeleeSubclassSelected Knight)
    , ClassOption "Rogue" (MeleeSubclassSelected Rogue)
    ]


rangedSubclassOptions : List ClassOption
rangedSubclassOptions =
    [ ClassOption "Ranger" (RangedSubclassSelected Ranger)
    , ClassOption "Axethrower" (RangedSubclassSelected Axethrower)
    ]


magicSubclassOptions : List ClassOption
magicSubclassOptions =
    [ ClassOption "Wizard" (MagicSubclassSelected Wizard)
    , ClassOption "Healer" (MagicSubclassSelected Healer)
    ]


viewClassOptions : List ClassOption -> Model -> Html Msg
viewClassOptions options model =
    div [ class "options" ]
        (List.map viewClassOption options)


viewClassOption : ClassOption -> Html Msg
viewClassOption option =
    button [ class "button", onClick option.msg ] [ text option.label ]


viewMainClassOptions : Model -> Html Msg
viewMainClassOptions =
    viewClassOptions mainClassOptions


viewSubclassOptions : Model -> Html Msg
viewSubclassOptions model =
    case getEmptyMainClass model.heroClass of
        AlmostMelee _ ->
            viewClassOptions meleeSubclassOptions model

        AlmostRanged _ ->
            viewClassOptions rangedSubclassOptions model

        AlmostMagic _ ->
            viewClassOptions magicSubclassOptions model


viewNameOptions : Model -> Html Msg
viewNameOptions model =
    div [ class "name-form" ]
        [ label [ class "label" ] [ text "Name" ]
        , input [ class "input", type_ "text", value model.heroName, onInput NameChanged ] []
        , button [ class "button", onClick CreateHero ] [ text "Let's goooo!" ]
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    div [ class "footer" ] []
