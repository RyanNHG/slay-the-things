module MainMenu exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (getCmd)
import Html exposing (..)
import Html.Attributes exposing (..)


type alias MenuButton =
    { label : String
    , onClick : Msg
    }


type alias Model =
    { title : String
    , buttons : List MenuButton
    }


type Msg
    = NewGameClicked


init : Context -> Model
init context =
    Model
        "Slay the Things!"
        [ (MenuButton "New Game" NewGameClicked)
        ]


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        NewGameClicked ->
            ( model
            , Cmd.none
            , getCmd <| Context.InitPage Context.HeroCreate
            )


view : Model -> Html Msg
view model =
    div [ class "main-menu" ]
        [ text model.title ]
