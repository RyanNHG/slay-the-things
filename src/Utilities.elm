module Utilities exposing (..)

import Task
import Types exposing (..)


getCmd : msg -> Cmd msg
getCmd msg =
    Task.perform identity (Task.succeed msg)


(!!) : aModel -> ( Cmd a, Cmd b ) -> ( aModel, Cmd a, Cmd b )
(!!) model ( a, b ) =
    ( model, a, b )


just : aModel -> ( aModel, Cmd a, Cmd b )
just model =
    ( model, Cmd.none, Cmd.none )


unpartition : ( List a, List a ) -> List a
unpartition ( a, b ) =
    a ++ b


rootImageFilepath : String
rootImageFilepath =
    "public/img/64x64/"


getHeroImageFilepath : HeroClass -> String
getHeroImageFilepath heroClass =
    let
        heroFilename =
            String.toLower <| getSubclassName heroClass
    in
        rootImageFilepath ++ "heroes/" ++ heroFilename ++ ".png"


getEnemyImageFilepath : EnemyType -> String
getEnemyImageFilepath enemyType =
    let
        enemyFilename =
            String.toLower <| getEnemyTypeName enemyType
    in
        rootImageFilepath ++ "enemies/" ++ enemyFilename ++ ".png"


getSubclassName : HeroClass -> String
getSubclassName heroClass =
    case heroClass of
        Melee subclass ->
            toString subclass

        Ranged subclass ->
            toString subclass

        Magic subclass ->
            toString subclass


getEnemyTypeName : EnemyType -> String
getEnemyTypeName enemyType =
    case enemyType of
        MeleeRange subclass ->
            toString subclass

        RangedRange subclass ->
            toString subclass


initStatus : Attributes -> Status
initStatus attributes =
    Status
        attributes.health
        attributes.magic
        []


initialAttributes : HeroClass -> Attributes
initialAttributes class =
    case class of
        Melee subclass ->
            case subclass of
                Knight ->
                    Attributes 4 4 3 4

                Rogue ->
                    Attributes 4 4 6 4

        Ranged subclass ->
            case subclass of
                Ranger ->
                    Attributes 4 4 9 4

                Axethrower ->
                    Attributes 4 4 4 4

        Magic subclass ->
            case subclass of
                Wizard ->
                    Attributes 4 4 4 4

                Cleric ->
                    Attributes 4 4 4 4
