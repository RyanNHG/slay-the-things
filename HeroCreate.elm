module HeroCreate exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (getCmd, just)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


type AlmostHeroClass
    = AlmostMelee (Maybe MeleeSubclass)
    | AlmostRanged (Maybe RangedSubclass)
    | AlmostMagic (Maybe MagicSubclass)


type alias Model =
    { heroClass : Maybe AlmostHeroClass
    , heroName : Maybe String
    }


type Msg
    = MainClassSelected AlmostHeroClass
    | MainClassReset
    | MeleeSubclassSelected MeleeSubclass
    | MeleeSubclassReset
    | RangedSubclassSelected RangedSubclass
    | RangedSubclassReset
    | MagicSubclassSelected MagicSubclass
    | MagicSubclassReset
    | NameSubmit String


init : Context -> Model
init context =
    Model
        Nothing
        Nothing


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
        MainClassSelected almostHeroClass ->
            just { model | heroClass = Just almostHeroClass }

        MainClassReset ->
            just { model | heroClass = Nothing }

        MeleeSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostMelee <| Just subclass }

        MeleeSubclassReset ->
            just { model | heroClass = Just <| AlmostMelee <| Nothing }

        RangedSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostRanged <| Just subclass }

        RangedSubclassReset ->
            just { model | heroClass = Just <| AlmostRanged <| Nothing }

        MagicSubclassSelected subclass ->
            just { model | heroClass = Just <| AlmostMagic <| Just subclass }

        MagicSubclassReset ->
            just { model | heroClass = Just <| AlmostMagic <| Nothing }

        NameSubmit name ->
            just { model | heroName = Just name }


view : Model -> Html Msg
view model =
    div [ class "hero-create" ]
        [ text "Hero Create" ]
