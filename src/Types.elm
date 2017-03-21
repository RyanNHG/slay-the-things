module Types exposing (..)

-- HERO


type alias Hero =
    { name : String
    , class : HeroClass
    , level : Int
    , attributes : HeroAttributes
    }


type HeroClass
    = Melee MeleeSubclass
    | Ranged RangedSubclass
    | Magic MagicSubclass


type MeleeSubclass
    = Knight
    | Rogue


type RangedSubclass
    = Ranger
    | Axethrower


type MagicSubclass
    = Wizard
    | Healer


type alias HeroAttributes =
    { damage : Int
    , health : Int
    , speed : Int
    , magic : Int
    }
