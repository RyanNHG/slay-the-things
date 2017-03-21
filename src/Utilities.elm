module Utilities exposing (..)

import Task


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
