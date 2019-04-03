module Pages.Deposits exposing (display)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Input.Number
import Models.User as User exposing (..)
import Msg exposing (..)
import Renderers.User as UserRenderer
import String.Extra


display : List User -> Int -> Html.Html Msg
display users depositQuantity =
    Html.div [ Attributes.class "row" ]
        [ Html.div [ Attributes.class "col-xs-12 col-md-offset-2 col-md-8" ]
            [ Html.div [ Attributes.class "card" ]
                [ Html.div [ Attributes.class "card--header" ]
                    [ Html.p [ Attributes.class "card--header-title" ]
                        [ Html.span [ Attributes.style [ ( "font-size", "25pt" ) ] ]
                            [ Html.text "💰" ]
                        , Html.text "Registar abono"
                        ]
                    , Html.p [ Attributes.class "card--header-subtitle" ]
                        [ Html.text "Aquí registrar un abono de un usuario a la caja." ]
                    ]
                , Html.div [] (List.indexedMap UserRenderer.display users)
                , Html.div [ Attributes.class "card--footer" ]
                    [ Html.div
                        [ Attributes.class "new-transaction" ]
                        [ Html.p [ Attributes.class "new-transaction--title" ]
                            [ Html.span [ Attributes.style [ ( "font-size", "20pt" ) ] ]
                                [ Html.text "💸" ]
                            , Html.text "Registrar deposito"
                            ]
                        , Html.br []
                            []
                        , Html.div [ Attributes.class "pure-form" ]
                            [ Html.div [ Attributes.class "new-transaction-register" ]
                                [ Html.div [ Attributes.class "new-transaction-register-user" ]
                                    [ Html.select [ Attributes.class "form-control", Attributes.style [ ( "width", "100%" ) ], Events.onInput Msg.SelectUserForDeposit ]
                                        (List.map (\user -> Html.option [ Attributes.value (toString user.identifier) ] [ Html.text <| String.Extra.toTitleCase user.name ]) users)
                                    ]
                                , Html.div [ Attributes.class "new-transaction-register-amount" ]
                                    [ Input.Number.input
                                        (Input.Number.Options
                                            -- maxLength
                                            (Just 4)
                                            -- maxValue
                                            (Just 500)
                                            -- minValue
                                            (Just 0)
                                            -- onInput
                                            Msg.SetDepositQuantity
                                            -- hasFocus
                                            Nothing
                                        )
                                        [ Attributes.class "form-control" ]
                                        (Just depositQuantity)
                                    ]
                                , Html.div [ Attributes.class "new-transaction-register-button", Events.onClick Msg.RegisterDeposit ]
                                    [ Html.text "Registrar Deposito" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
