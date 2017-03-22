module CombatView exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (..)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { title : String
    , heroName : Maybe String
    }


type Msg
    = NoOp
    | GoToMainMenu


init : Context -> Model
init context =
    Model
        "That's not ready yet!"
        (Maybe.map getName context.hero)


getName : Hero -> String
getName hero =
    hero.name


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        NoOp ->
            just model

        GoToMainMenu ->
            ( model, Cmd.none, getCmd <| Context.GotoPage Context.MainMenu )


view : Model -> Html Msg
view model =
    div [ class "combat-view" ]
        [ h3 []
            [ text <|
                case model.heroName of
                    Just name ->
                        "Sorry, " ++ name ++ "!"

                    Nothing ->
                        ""
            ]
        , h4 [] [ text model.title ]
        , button [ class "button", onClick GoToMainMenu ] [ text "Make another hero?" ]
        ]
