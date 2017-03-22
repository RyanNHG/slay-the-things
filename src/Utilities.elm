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
            getHeroImageFilename heroClass
    in
        rootImageFilepath ++ "heroes/" ++ heroFilename ++ ".png"


getEnemyImageFilepath : EnemyType -> String
getEnemyImageFilepath enemyType =
    let
        enemyFilename =
            getEnemyImageFilename enemyType
    in
        rootImageFilepath ++ "enemies/" ++ enemyFilename ++ ".png"


getHeroImageFilename : HeroClass -> String
getHeroImageFilename heroClass =
    String.toLower <|
        case heroClass of
            Melee subclass ->
                toString subclass

            Ranged subclass ->
                toString subclass

            Magic subclass ->
                toString subclass


getEnemyImageFilename : EnemyType -> String
getEnemyImageFilename enemyType =
    enemyType
        |> toString
        |> String.toLower
