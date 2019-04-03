module Model exposing (Model)

import Models.Page exposing (..)
import Models.Transaction exposing (..)
import Models.User exposing (..)


type alias Model =
    { users : List User
    , loadingUsers : String
    , selectedUser : Int
    , quantity : Int
    , transactions : List Transaction
    , availableUsers : List User
    , currentPage : Page
    , creatingUser : String
    , newUserName : String
    , newUserBalance : Int
    , selectedUserForDeposit : Int
    , depositQuantity : Int
    , allUsersVisible : Bool
    , addingDeposit : String
    , addingTransactions : String

    -- flags
    , successPageUrl : String
    , getUsersUrl : String
    , createNewUserUrl : String
    , addDepositUrl : String
    , addTransactionsUrl : String
    , csrf_token : String
    }
