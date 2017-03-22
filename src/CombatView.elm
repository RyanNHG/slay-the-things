module CombatView exposing (Model, Msg, init, update, view)

import Context exposing (Context)
import Utilities exposing (..)
import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


emptyHtml : Html Msg
emptyHtml =
    text ""


type alias Actor =
    { actorType : ActorType
    , coordinates : Coordinates
    }


type ActorType
    = HeroActor Hero
    | EnemyActor Enemy


type alias Coordinates =
    ( Int, Int )


type alias ActorAction =
    { label : String
    , msg : Msg
    }


type alias ActorDetails =
    { name : String
    , level : Int
    , className : String
    , status : Status
    , attributes : Attributes
    , selectActions : List ActorAction
    , attackActions : List ActorAction
    , moveActions : List ActorAction
    }


type ClickState
    = Select
    | Attack
    | Move
    | Disabled


type alias Model =
    { actors : List Actor
    , selectedActor : Maybe Actor
    , clickState : ClickState
    }


type Msg
    = NoOp
    | GoToMainMenu
    | ClickCell Coordinates
    | SetClickState ClickState


boardDimensions : Coordinates
boardDimensions =
    ( 7, 5 )


init : Context -> Model
init context =
    Model
        (initActors context.hero)
        Nothing
        Select


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
            MeleeRange Skeleton

        enemyCoordinates =
            [ ( 6, 2 ), ( 6, 4 ) ]

        enemyAttributes =
            (Attributes 4 4 4 4)

        enemy =
            Enemy enemyType 1 (initStatus enemyAttributes) enemyAttributes

        enemiesActors =
            [ Actor (EnemyActor enemy) ( 6, 2 )
            , Actor (EnemyActor enemy) ( 6, 4 )
            ]
    in
        heroActors ++ enemiesActors


getActorDetails : Actor -> ActorDetails
getActorDetails actor =
    case actor.actorType of
        HeroActor hero ->
            ActorDetails
                hero.name
                hero.level
                (getSubclassName hero.class)
                hero.status
                hero.attributes
                [ ActorAction "Attack" (SetClickState Attack)
                , ActorAction "Move" (SetClickState Move)
                ]
                [ ActorAction "Cancel" (SetClickState Select)
                ]
                [ ActorAction "Cancel" (SetClickState Select)
                ]

        EnemyActor enemy ->
            ActorDetails
                (getEnemyTypeName enemy.type_)
                enemy.level
                (getEnemyTypeName enemy.type_)
                enemy.status
                enemy.attributes
                []
                []
                []


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
update msg model =
    case msg of
        NoOp ->
            just model

        GoToMainMenu ->
            ( model, Cmd.none, getCmd <| Context.GotoPage Context.MainMenu )

        ClickCell coordinates ->
            case model.clickState of
                Select ->
                    getInfoAt coordinates model

                Attack ->
                    just model

                Move ->
                    just model

                Disabled ->
                    just model

        SetClickState clickState ->
            just { model | clickState = clickState }


getInfoAt : Coordinates -> Model -> ( Model, Cmd Msg, Cmd Context.Msg )
getInfoAt coordinates model =
    just { model | selectedActor = getActorAt coordinates model }


view : Model -> Html Msg
view model =
    div [ class "combat-view" ]
        [ viewCombatBoard model
        , viewActorDetails model
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
        coordinates =
            ( x, y )

        selectedClass =
            if hasSelectedActor model coordinates then
                "selected"
            else
                ""

        attackableClass =
            if isAttackableBySelectedActor model ( x, y ) then
                "attackable"
            else
                ""

        walkableClass =
            if isWalkableToSelectedActor model ( x, y ) then
                "walkable"
            else
                ""

        classes =
            "board-cell"
                :: ([ selectedClass ] ++ [ attackableClass ] ++ [ walkableClass ])
                |> List.filter (\str -> str /= "")

        actors =
            viewActorsAt ( x, y ) model
    in
        div [ class <| String.join " " classes, onClick (ClickCell ( x, y )) ]
            [ div [ class "actors floating" ] actors
            ]


hasSelectedActor : Model -> Coordinates -> Bool
hasSelectedActor model coordinates =
    case model.selectedActor of
        Just actor ->
            coordinates == actor.coordinates

        Nothing ->
            False


isAttackableBySelectedActor : Model -> Coordinates -> Bool
isAttackableBySelectedActor model coordinates =
    case model.selectedActor of
        Just actor ->
            inAttackRange coordinates actor
                && model.clickState
                == Attack
                && getActorAt coordinates model
                /= Nothing
                && coordinates
                /= actor.coordinates

        Nothing ->
            False


isWalkableToSelectedActor : Model -> Coordinates -> Bool
isWalkableToSelectedActor model coordinates =
    case model.selectedActor of
        Just actor ->
            inWalkingRange coordinates actor
                && model.clickState
                == Move
                && getActorAt coordinates model
                == Nothing

        Nothing ->
            False


inAttackRange : Coordinates -> Actor -> Bool
inAttackRange coordinates actor =
    case actor.actorType of
        HeroActor hero ->
            case hero.class of
                Melee _ ->
                    withinDistance actor.coordinates coordinates 1

                _ ->
                    withinDistance actor.coordinates coordinates 2

        EnemyActor enemy ->
            case enemy.type_ of
                MeleeRange _ ->
                    withinDistance actor.coordinates coordinates 1

                _ ->
                    withinDistance actor.coordinates coordinates 2


inWalkingRange : Coordinates -> Actor -> Bool
inWalkingRange coordinates actor =
    case actor.actorType of
        HeroActor hero ->
            withinDistance actor.coordinates coordinates (getMoveRange hero.attributes.speed)

        EnemyActor enemy ->
            withinDistance actor.coordinates coordinates (getMoveRange enemy.attributes.speed)


getMoveRange : Int -> Int
getMoveRange speed =
    speed // 4 + 1


withinDistance : Coordinates -> Coordinates -> Int -> Bool
withinDistance ( x1, y1 ) ( x2, y2 ) range =
    ((x1 - x2) * (x1 - x2) <= range * range) && ((y1 - y2) * (y1 - y2) <= range * range)


getActorsAt : Coordinates -> Model -> List Actor
getActorsAt coordinates model =
    model.actors
        |> List.filter (\actor -> actor.coordinates == coordinates)


viewActorsAt : Coordinates -> Model -> List (Html Msg)
viewActorsAt coordinates model =
    getActorsAt coordinates model
        |> List.map
            (\actor ->
                div [ class "actor expandUp" ]
                    [ img
                        [ src <| getActorImageFilePath actor
                        , class "full-width"
                        ]
                        []
                    ]
            )


getActorAt : Coordinates -> Model -> Maybe Actor
getActorAt coordinates model =
    List.head <| getActorsAt coordinates model


getActorImageFilePath : Actor -> String
getActorImageFilePath actor =
    case actor.actorType of
        HeroActor hero ->
            getHeroImageFilepath hero.class

        EnemyActor enemy ->
            getEnemyImageFilepath enemy.type_


viewActorDetails : Model -> Html Msg
viewActorDetails model =
    case Maybe.map getActorDetails model.selectedActor of
        Just actorDetails ->
            div [ class "actor-details" ]
                [ h4 [ class "title" ] [ text actorDetails.name ]
                , h5 [ class "subtitle" ] [ text <| "Lvl " ++ (toString actorDetails.level) ++ " " ++ actorDetails.className ]
                , viewActorStatus actorDetails
                , viewActorActions actorDetails model.clickState
                ]

        Nothing ->
            emptyHtml


viewActorStatus : ActorDetails -> Html Msg
viewActorStatus actorDetails =
    div [ class "actor-status" ]
        [ viewHealthbar actorDetails
        , viewManabar actorDetails
        ]


viewHealthbar : ActorDetails -> Html Msg
viewHealthbar actorDetails =
    div [ class "status-bar health" ]
        [ div [ class "available", style [ ( "width", getHealthPercent actorDetails ) ] ] []
        ]


viewManabar : ActorDetails -> Html Msg
viewManabar actorDetails =
    div [ class "status-bar mana" ]
        [ div [ class "available", style [ ( "width", getManaPercent actorDetails ) ] ] []
        ]


getHealthPercent : ActorDetails -> String
getHealthPercent actorDetails =
    actorDetails.status.health
        |> toFloat
        |> (/) (toFloat <| actorDetails.attributes.health)
        |> toString
        |> (++) "%"


getManaPercent : ActorDetails -> String
getManaPercent actorDetails =
    actorDetails.status.mana
        |> toFloat
        |> (/) (toFloat <| actorDetails.attributes.magic)
        |> toString
        |> (++) "%"


viewActorActions : ActorDetails -> ClickState -> Html Msg
viewActorActions actorDetails clickState =
    div [ class "actor-actions" ]
        (List.map
            (viewActorAction actorDetails)
            (getActions actorDetails clickState)
        )


getActions : ActorDetails -> ClickState -> List ActorAction
getActions actorDetails clickState =
    case clickState of
        Select ->
            actorDetails.selectActions

        Attack ->
            actorDetails.attackActions

        Move ->
            actorDetails.moveActions

        Disabled ->
            []


viewActorAction : ActorDetails -> ActorAction -> Html Msg
viewActorAction actorDetails action =
    button [ class "button", onClick action.msg ]
        [ text action.label ]
