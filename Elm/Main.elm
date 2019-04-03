module Main exposing (initialModel, main, msgToCmd, update, view)

import Flags exposing (Flags)
import Html
import Html.Attributes as Attributes
import Model as Model exposing (Model)
import Models.Page as Page exposing (Page)
import Models.Transaction as Transaction exposing (Transaction)
import Models.User as User exposing (User)
import Msg as Msg exposing (Msg)
import Navigation
import Pages.Cart as Cart
import Pages.Deposits as Deposits
import Pages.Users as Users
import Platform.Cmd
import Platform.Sub
import Renderers.Footer as Footer
import Rest.AddDeposit as AddDeposit
import Rest.CreateErrorMessage as CreateErrorMessage
import Rest.CreateUser as CreateUser
import Rest.RegisterTransactions as RegisterTransactions
import Rest.UsersLoader as UsersLoader
import Task


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = \_ -> Platform.Sub.none
        }



-- Model


initialModel : Flags -> ( Model, Cmd Msg )
initialModel flags =
    ( Model
        -- users
        []
        -- loading users (empty string means loading)
        ""
        -- selectedUser
        0
        -- quantity
        0
        -- transactions
        []
        -- availableUsers
        []
        --currentPage
        Page.Cart
        -- creatingUser (empty string means loading)
        ""
        -- newUserName
        ""
        -- newUserBalance
        0
        -- selectedUserForDeposit
        0
        -- depositQuantity
        0
        -- alUsersVisible
        False
        -- addingDeposit
        ""
        -- addingTransactions
        ""
        -- flags
        flags.successPageUrl
        flags.getUsersUrl
        flags.createNewUserUrl
        flags.addDepositUrl
        flags.addTransactionsUrl
        flags.csrf_token
    , Platform.Cmd.batch [ msgToCmd Msg.LoadUsers ]
    )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --*******************************************************************************************
        --************************************** REST MESSAGES **************************************
        --*******************************************************************************************
        Msg.LoadUsers ->
            ( { model | loadingUsers = "loading" }, UsersLoader.getUsersCommand model.getUsersUrl )

        Msg.UsersDataReceived (Ok users) ->
            case List.head users of
                Nothing ->
                    ( model, Cmd.none )

                Just firstUser ->
                    ( { model | users = users, availableUsers = users, loadingUsers = "", selectedUser = firstUser.identifier, selectedUserForDeposit = firstUser.identifier }, Cmd.none )

        Msg.UsersDataReceived (Err httpError) ->
            ( { model | loadingUsers = CreateErrorMessage.createErrorMessage httpError }, Cmd.none )

        Msg.CreateNewUser ->
            ( { model | creatingUser = "loading" }, CreateUser.createUserCommand (User 0 model.newUserName model.newUserBalance) model.createNewUserUrl model.csrf_token )

        Msg.NewUserDataReceived (Ok user) ->
            ( { model | creatingUser = "", newUserBalance = 0, newUserName = "", currentPage = Page.Cart }, msgToCmd Msg.LoadUsers )

        Msg.NewUserDataReceived (Err httpError) ->
            ( { model | creatingUser = CreateErrorMessage.createErrorMessage httpError, newUserBalance = 0, newUserName = "" }, Cmd.none )

        Msg.NewDepositDataReceived (Ok transaction) ->
            ( { model | addingDeposit = "", selectedUserForDeposit = 0, depositQuantity = 0, currentPage = Page.Users }, msgToCmd Msg.LoadUsers )

        Msg.NewDepositDataReceived (Err httpError) ->
            ( { model | addingDeposit = CreateErrorMessage.createErrorMessage httpError, selectedUserForDeposit = 0, depositQuantity = 0 }, Cmd.none )

        Msg.NewTransactionsDataReceived (Ok transactions) ->
            ( { model | addingTransactions = "", transactions = [], currentPage = Page.Cart }, msgToCmd Msg.LoadUsers )

        Msg.NewTransactionsDataReceived (Err httpError) ->
            ( { model | addingTransactions = CreateErrorMessage.createErrorMessage httpError, transactions = [] }, Cmd.none )

        --*******************************************************************************************
        --************************************** PAGE MESSAGES **************************************
        --*******************************************************************************************
        Msg.ChangePage page ->
            ( { model | currentPage = page }, Cmd.none )

        --*******************************************************************************************
        --************************************** CART MESSAGES **************************************
        --*******************************************************************************************
        Msg.SelectUser id ->
            case String.toInt id of
                Ok val ->
                    ( { model | selectedUser = val }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Msg.SetQuantity quantity ->
            case quantity of
                Just q ->
                    ( { model | quantity = q }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Msg.AddTransaction ->
            let
                users =
                    List.filter (\user -> user.identifier == model.selectedUser) model.users
            in
            case List.head users of
                Nothing ->
                    ( model, msgToCmd Msg.CalculateAvailableUsers )

                Just user ->
                    if model.selectedUser /= 0 && model.quantity /= 0 && user.name /= "" then
                        ( { model | transactions = Transaction model.selectedUser user.name (-1 * model.quantity) :: model.transactions }, msgToCmd Msg.CalculateAvailableUsers )

                    else
                        ( model, msgToCmd Msg.CalculateAvailableUsers )

        Msg.RemoveTransaction userId ->
            let
                remainingTransactions =
                    List.filter (\t -> t.userIdentifier /= userId) model.transactions
            in
            ( { model | transactions = remainingTransactions }, msgToCmd Msg.CalculateAvailableUsers )

        Msg.CalculateAvailableUsers ->
            let
                userIdsInTransactions =
                    List.map (\transaction -> transaction.userIdentifier) model.transactions

                availableUsers =
                    List.filter (\user -> not (List.member user.identifier userIdsInTransactions)) model.users
            in
            case List.head availableUsers of
                Nothing ->
                    ( { model | availableUsers = availableUsers, selectedUser = 0, quantity = 0 }, Cmd.none )

                Just firstUser ->
                    ( { model | availableUsers = availableUsers, selectedUser = firstUser.identifier }, Cmd.none )

        Msg.SetNewUserBalance quantity ->
            case quantity of
                Just q ->
                    ( { model | newUserBalance = q }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Msg.SetNewUserName name ->
            ( { model | newUserName = name }, Cmd.none )

        Msg.SelectUserForDeposit id ->
            case String.toInt id of
                Ok val ->
                    ( { model | selectedUserForDeposit = val }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Msg.SetDepositQuantity quantity ->
            case quantity of
                Just q ->
                    ( { model | depositQuantity = q }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Msg.RegisterDeposit ->
            let
                user =
                    List.head <| List.filter (\user -> model.selectedUserForDeposit == user.identifier) model.users
            in
            case user of
                Nothing ->
                    ( model, Cmd.none )

                Just u ->
                    ( model, AddDeposit.addDepositCommand (Transaction u.identifier u.name model.depositQuantity) model.addDepositUrl model.csrf_token )

        Msg.RegisterTransactions ->
            ( model, RegisterTransactions.registerTransactionsCommand model.transactions model.addTransactionsUrl model.csrf_token )

        --*******************************************************************************************
        --********************************** MISCELANEOUS MESSAGES **********************************
        --*******************************************************************************************
        Msg.ViewAllUsers ->
            ( { model | allUsersVisible = True }, Cmd.none )



-- Turn a Msg into a Cmd.Msg


msgToCmd : msg -> Cmd msg
msgToCmd msg =
    Task.succeed msg
        |> Task.perform identity


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.header [ Attributes.class "container center-xs" ]
            [ Html.div [ Attributes.class "row " ]
                [ Html.div [ Attributes.class "col-xs" ]
                    [ Html.br [] []
                    , Html.br [] []
                    , Html.br [] []
                    , Html.img [ Attributes.src "public/img/logo.png", Attributes.style [ ( "max-width", "211px" ) ], Attributes.alt "Don Caja" ] []
                    , Html.br [] []
                    , Html.br [] []
                    , Html.br [] []
                    , Html.br [] []
                    ]
                ]
            ]
        , case model.currentPage of
            Page.Cart ->
                Html.div [ Attributes.class "content container" ]
                    [ Cart.display model
                    , Html.br [] []
                    , Html.br [] []
                    ]

            Page.Deposits ->
                Html.div [ Attributes.class "content container" ]
                    [ Deposits.display model.users model.depositQuantity
                    , Html.br [] []
                    , Html.br [] []
                    ]

            Page.Users ->
                Html.div [ Attributes.class "content container" ]
                    [ Users.display model.users model.newUserName model.newUserBalance model.creatingUser
                    , Html.br [] []
                    , Html.br [] []
                    ]
        , Footer.display model.currentPage
        ]
