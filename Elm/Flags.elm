module Flags exposing (Flags)


type alias Flags =
    { successPageUrl : String
    , getUsersUrl : String
    , createNewUserUrl : String
    , addDepositUrl : String
    , addTransactionsUrl : String
    , csrf_token : String
    }
