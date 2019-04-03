module Rest.AddDeposit exposing (addDepositCommand)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline
import Json.Encode as Encode
import Models.Transaction exposing (..)
import Msg exposing (Msg)


transactionDecoder : Json.Decoder Transaction
transactionDecoder =
    JsonPipeline.decode Transaction
        |> JsonPipeline.required "user_id" Json.int
        |> JsonPipeline.required "name" Json.string
        |> JsonPipeline.required "amount" Json.int


addDepositCommand : Transaction -> String -> String -> Cmd Msg
addDepositCommand transaction addDepositUrl csrf_token =
    addDepositRequest transaction addDepositUrl csrf_token
        |> Http.send Msg.NewDepositDataReceived


addDepositRequest : Transaction -> String -> String -> Http.Request Transaction
addDepositRequest transaction addDepositUrl csrf_token =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-CSRF-TOKEN" csrf_token ]
        , url = addDepositUrl
        , body = Http.jsonBody (transactionEncoder transaction)
        , expect = Http.expectJson transactionDecoder
        , timeout = Nothing
        , withCredentials = False
        }


transactionEncoder : Transaction -> Encode.Value
transactionEncoder transaction =
    Encode.object
        [ ( "user_id", Encode.int transaction.userIdentifier )
        , ( "name", Encode.string transaction.userName )
        , ( "amount", Encode.int transaction.amount )
        ]
