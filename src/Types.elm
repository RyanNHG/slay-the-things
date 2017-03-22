module Types exposing (..)

-- ENEMY


type alias Enemy =
    { type_ : EnemyType
    , level : Int
    , status : Status
    , attributes : Attributes
    }


type EnemyType
    = MeleeRange EnemyClass
    | RangedRange EnemyClass


type EnemyClass
    = Skeleton
    | GoblinArcher
    | Wolf



-- HERO


type alias Hero =
    { name : String
    , class : HeroClass
    , level : Int
    , status : Status
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



-- ACTOR


type alias Status =
    { health : Int
    , mana : Int
    , effects : List StatusEffect
    }


type StatusEffect
    = Stunned
    | Dead


type alias Attributes =
    { damage : Int
    , health : Int
    , speed : Int
    , magic : Int
    }
