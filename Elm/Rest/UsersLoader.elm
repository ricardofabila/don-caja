module Rest.UsersLoader exposing (getUsersCommand)

import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JsonPipeline
import Models.User as User exposing (User)
import Msg exposing (Msg)


usersDecoder : Json.Decoder User
usersDecoder =
    JsonPipeline.decode User
        |> JsonPipeline.required "id" Json.int
        |> JsonPipeline.required "name" Json.string
        |> JsonPipeline.required "balance" Json.int


getUsersCommand : String -> Cmd Msg
getUsersCommand getUsersUrl =
    Json.list usersDecoder
        |> Http.get getUsersUrl
        |> Http.send Msg.UsersDataReceived
