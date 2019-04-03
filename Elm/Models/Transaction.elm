module Models.Transaction exposing (Transaction)


type alias Transaction =
    { userIdentifier : Int
    , userName : String
    , amount : Int
    }
