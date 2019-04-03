module Rest.CreateUser exposing (createUserCommand)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline
import Json.Encode as Encode
import Models.User exposing (..)
import Msg exposing (Msg)


usersDecoder : Json.Decoder User
usersDecoder =
    JsonPipeline.decode User
        |> JsonPipeline.required "id" Json.int
        |> JsonPipeline.required "name" Json.string
        |> JsonPipeline.required "balance" Json.int


createUserCommand : User -> String -> String -> Cmd Msg
createUserCommand user createNewUserUrl csrf_token =
    createUserRequest user createNewUserUrl csrf_token
        |> Http.send Msg.NewUserDataReceived


createUserRequest : User -> String -> String -> Http.Request User
createUserRequest user createNewUserUrl csrf_token =
    Http.request
        { method = "POST"
        , headers = [ Http.header "X-CSRF-TOKEN" csrf_token ]
        , url = createNewUserUrl
        , body = Http.jsonBody (userEncoder user)
        , expect = Http.expectJson usersDecoder
        , timeout = Nothing
        , withCredentials = False
        }


userEncoder : User -> Encode.Value
userEncoder user =
    Encode.object
        [ ( "name", Encode.string user.name )
        , ( "balance", Encode.int user.balance )
        ]
