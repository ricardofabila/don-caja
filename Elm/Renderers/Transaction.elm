module Renderers.Transaction exposing (create, display)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Input.Number
import Models.Transaction exposing (..)
import Models.User exposing (..)
import Msg exposing (..)
import Round
import String.Extra


display : Int -> Transaction -> Html.Html Msg
display index transaction =
    let
        extraClass =
            case index % 2 of
                0 ->
                    "transaction__yellow"

                _ ->
                    ""
    in
    Html.div [ Attributes.class <| "transaction " ++ extraClass ]
        [ Html.div [ Attributes.class "transaction--cross", Events.onClick <| Msg.RemoveTransaction transaction.userIdentifier ]
            [ Html.text "❌" ]
        , Html.div [ Attributes.class "transaction--name" ]
            [ Html.text <| String.Extra.toTitleCase transaction.userName ]
        , Html.div [ Attributes.class "transaction--amount" ]
            [ Html.text ((++) "$" <| Round.round 2 <| toFloat transaction.amount) ]
        ]


create : List User -> List Transaction -> Int -> Html.Html Msg
create availableUsers transactions quantity =
    Html.div [ Attributes.class "pure-form" ]
        [ Html.div [ Attributes.class "new-transaction-register" ]
            [ Html.div [ Attributes.class "new-transaction-register-user" ]
                [ Html.select [ Attributes.class "form-control", Attributes.style [ ( "width", "100%" ) ], Events.onInput Msg.SelectUser ]
                    (List.map (\user -> Html.option [ Attributes.value (toString user.identifier) ] [ Html.text <| String.Extra.toTitleCase user.name ]) availableUsers)
                ]
            , Html.div [ Attributes.class "new-transaction-register-amount" ]
                [ Input.Number.input
                    (Input.Number.Options
                        -- maxLength
                        (Just 4)
                        -- maxValue
                        (Just 200)
                        -- minValue
                        (Just 0)
                        -- onInput
                        Msg.SetQuantity
                        -- hasFocus
                        Nothing
                    )
                    [ Attributes.class "form-control" ]
                    (Just quantity)
                ]
            , Html.div [ Attributes.class "new-transaction-register-button", Events.onClick Msg.AddTransaction ]
                [ Html.text "Registrar Compra" ]
            ]
        ]
