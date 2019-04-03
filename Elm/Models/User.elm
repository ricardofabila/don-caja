module Models.User exposing (User)


type alias User =
    { identifier : Int
    , name : String
    , balance : Int
    }
