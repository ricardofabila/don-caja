module Msg exposing (Msg(..))

import Http
import Models.Page exposing (..)
import Models.Transaction exposing (..)
import Models.User exposing (..)


type Msg
    = SelectUser String
    | SetQuantity (Maybe Int)
    | AddTransaction
    | RemoveTransaction Int
    | CalculateAvailableUsers
    | ChangePage Page
    | SetNewUserBalance (Maybe Int)
    | SetNewUserName String
    | SelectUserForDeposit String
    | SetDepositQuantity (Maybe Int)
    | ViewAllUsers
      -- Rest
    | LoadUsers
    | UsersDataReceived (Result Http.Error (List User))
    | CreateNewUser
    | NewUserDataReceived (Result Http.Error User)
    | RegisterDeposit
    | NewDepositDataReceived (Result Http.Error Transaction)
    | RegisterTransactions
    | NewTransactionsDataReceived (Result Http.Error (List Transaction))
