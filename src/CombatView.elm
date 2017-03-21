module CombatView exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (..)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { title : String
    }


type Msg
    = NoOp


init : Context -> Model
init context =
    Model
        "Fight begin!"


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        NoOp ->
            just model


view : Model -> Html Msg
view model =
    div [ class "combat-view" ]
        [ text model.title ]
