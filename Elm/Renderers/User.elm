module Renderers.User exposing (display)

import Html
import Html.Attributes as Attributes
import Models.User exposing (..)
import Msg exposing (..)
import Round
import String.Extra


display : Int -> User -> Html.Html Msg
display index user =
    let
        extraClass =
            case index % 2 of
                0 ->
                    "transaction__yellow"

                _ ->
                    ""
    in
    Html.div [ Attributes.class <| "account " ++ extraClass ]
        [ Html.div [ Attributes.class "account--name" ]
            [ Html.text <| String.Extra.toTitleCase user.name ]
        , if user.balance <= 0 then
            Html.div [ Attributes.class "account--amount account--amount-red" ]
                [ Html.text ((++) "$" <| Round.round 2 <| toFloat user.balance) ]

          else
            Html.div [ Attributes.class "account--amount" ]
                [ Html.text ((++) "$" <| Round.round 2 <| toFloat user.balance) ]
        ]
