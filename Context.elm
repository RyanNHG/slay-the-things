module Context exposing (..)

import Types exposing (Hero)


type alias Context =
    { hero : Maybe Hero
    , heroes : List Hero
    , page : Page
    }


type Msg
    = GotoPage Page
    | InitPage Page


type Page
    = MainMenu
    | HeroCreate



-- | MapView
-- | RoadView
-- | CombatView
