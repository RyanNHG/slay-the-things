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
    , actors : List Actor
    }


type alias Actor =
    { actorType : ActorType
    , coordinates : Coordinates
    }


type ActorType
    = HeroActor Hero
    | EnemyActor Enemy


type Msg
    = NoOp
    | GoToMainMenu


type alias Coordinates =
    ( Int, Int )


boardDimensions : Coordinates
boardDimensions =
    ( 7, 5 )


init : Context -> Model
init context =
    Model
        "That's not ready yet!"
        (Maybe.map getName context.hero)
        (initActors context.hero)


initActors : Maybe Hero -> List Actor
initActors maybeHero =
    case maybeHero of
        Just hero ->
            initCombatForHero hero

        Nothing ->
            []


initCombatForHero : Hero -> List Actor
initCombatForHero hero =
    let
        heroActors =
            [ Actor (HeroActor hero) ( 2, 3 ) ]

        -- TODO: Randomize enemies and positions
        enemyCount =
            2

        enemyType =
            Skeleton

        enemyCoordinates =
            [ ( 6, 2 ), ( 6, 4 ) ]

        enemy =
            Enemy enemyType 1 (Attributes 4 4 4 4)

        enemiesActors =
            [ Actor (EnemyActor enemy) ( 6, 2 )
            , Actor (EnemyActor enemy) ( 6, 4 )
            ]
    in
        heroActors ++ enemiesActors


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
        [ viewCombatBoard model
        ]


viewCombatBoard : Model -> Html Msg
viewCombatBoard model =
    let
        ( numRows, numCols ) =
            boardDimensions

        rows =
            List.map (viewCombatBoardRow model numCols) (List.range 1 numRows)
    in
        div [ class "board", style (getStyle boardDimensions) ] rows


getStyle : Coordinates -> List ( String, String )
getStyle ( numRows, numCols ) =
    if numRows > numCols then
        [ ( "width", (toString 100) ++ "vmin" )
        , ( "height", (toString (100 * numCols // numRows)) ++ "vmin" )
        ]
    else
        [ ( "height", (toString 100) ++ "vmin" )
        , ( "width", (toString (100 * numRows // numCols)) ++ "vmin" )
        ]


viewCombatBoardRow : Model -> Int -> Int -> Html Msg
viewCombatBoardRow model numCells xIndex =
    let
        cells =
            List.map (viewCombatBoardCell model xIndex) (List.range 1 numCells)
    in
        div [ class "board-row" ] cells


viewCombatBoardCell : Model -> Int -> Int -> Html Msg
viewCombatBoardCell model x y =
    let
        actors =
            getActorsAt ( x, y ) model
    in
        div [ class "board-cell" ]
            [ div [ class "actors" ] actors
            ]


getActorsAt : Coordinates -> Model -> List (Html Msg)
getActorsAt coordinates model =
    model.actors
        |> List.filter (\actor -> actor.coordinates == coordinates)
        |> List.map
            (\actor ->
                div [ class "actor" ]
                    [ img
                        [ src <| getActorImageFilePath actor
                        , class ""
                        ]
                        []
                    ]
            )


getActorImageFilePath : Actor -> String
getActorImageFilePath actor =
    case actor.actorType of
        HeroActor hero ->
            getHeroImageFilepath hero.class

        EnemyActor enemy ->
            getEnemyImageFilepath enemy.type_
