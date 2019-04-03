module Rest.CreateErrorMessage exposing (createErrorMessage)

import Http


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "El servidor esta tomando mucho tiempo en responder. Por favor, intenta en otro momento."

        Http.NetworkError ->
            "Parece ser que hay un error en tu conección a internet o existe un problema con la red."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message
