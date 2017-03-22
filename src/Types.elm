module Types exposing (..)

-- HERO


type alias Enemy =
    { type_ : EnemyType
    , level : Int
    , attributes : Attributes
    }


type EnemyType
    = Skeleton
    | GoblinArcher
    | Wolf


type alias Hero =
    { name : String
    , class : HeroClass
    , level : Int
    , attributes : Attributes
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
    | Cleric


type alias Attributes =
    { damage : Int
    , health : Int
    , speed : Int
    , magic : Int
    }
