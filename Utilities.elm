module Utilities exposing (getCmd)

import Task


getCmd : msg -> Cmd msg
getCmd msg =
    Task.perform identity (Task.succeed msg)
