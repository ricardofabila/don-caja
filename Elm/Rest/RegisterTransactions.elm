module Rest.RegisterTransactions exposing (registerTransactionsCommand)

import Array
import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline
import Json.Encode as Encode
import Models.Transaction exposing (..)
import Msg exposing (Msg)


transactionsDecoder : Json.Decoder (List Transaction)
transactionsDecoder =
    Json.list
        (JsonPipeline.decode Transaction
            |> JsonPipeline.required "user_id" Json.int
            |> JsonPipeline.required "name" Json.string
            |> JsonPipeline.required "amount" Json.int
        )


registerTransactionsCommand : List Transaction -> String -> String -> Cmd Msg
registerTransactionsCommand transactions addTransactionsUrl csrf_token =
    registerTransactionsRequest transactions addTransactionsUrl csrf_token
        |> Http.send Msg.NewTransactionsDataReceived


registerTransactionsRequest : List Transaction -> String -> String -> Http.Request (List Transaction)
registerTransactionsRequest transactions addTransactionsUrl csrf_token =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-CSRF-TOKEN" csrf_token ]
        , url = addTransactionsUrl
        , body = Http.jsonBody (transactionsEncoder transactions)
        , expect = Http.expectJson transactionsDecoder
        , timeout = Nothing
        , withCredentials = False
        }


transactionsEncoder : List Transaction -> Encode.Value
transactionsEncoder transactions =
    let
        encodedTransactions =
            List.map transactionEncoder transactions
    in
    Encode.array <| Array.fromList encodedTransactions


transactionEncoder : Transaction -> Encode.Value
transactionEncoder transaction =
    Encode.object
        [ ( "user_id", Encode.int transaction.userIdentifier )
        , ( "name", Encode.string transaction.userName )
        , ( "amount", Encode.int transaction.amount )
        ]
