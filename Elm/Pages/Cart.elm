module Pages.Cart exposing (display)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (..)
import Msg exposing (..)
import Renderers.Transaction as TransactionRenderer
import Renderers.User as UserRenderer
import Round as Round


display : Model -> Html.Html Msg
display model =
    Html.div [ Attributes.class "row" ]
        [ Html.div [ Attributes.class "col-xs-12 col-sm-12 col-md-7" ]
            [ Html.div [ Attributes.class "card" ]
                [ Html.div [ Attributes.class "card--header" ]
                    [ Html.p [ Attributes.class "card--header-title" ]
                        [ Html.span [ Attributes.style [ ( "font-size", "25pt" ) ] ]
                            [ Html.text "🍛" ]
                        , Html.text "Transacciones"
                        ]
                    , Html.p [ Attributes.class "card--header-subtitle" ]
                        [ Html.text "Aquí registrar nuevas transacciones por compras de comida." ]
                    ]
                , Html.div [] (List.indexedMap TransactionRenderer.display model.transactions)
                , Html.div [ Attributes.class "card--footer" ]
                    [ Html.div [ Attributes.class "transactions--total" ]
                        [ Html.div [ Attributes.style [ ( "width", "200px" ) ] ]
                            [ Html.p [ Attributes.class "transactions--total-text" ]
                                [ Html.span []
                                    [ Html.text "En caja: " ]
                                , Html.span []
                                    [ Html.text <| (++) " $" <| Round.round 2 (toFloat <| List.sum (List.map (\u -> u.balance) model.users)) ]
                                ]
                            , Html.p [ Attributes.class "transactions--total-text" ]
                                [ Html.span []
                                    [ Html.text "Total: " ]
                                , Html.span []
                                    [ Html.text <| (++) " $" <| Round.round 2 (toFloat <| List.sum (List.map (\t -> t.amount) model.transactions)) ]
                                ]
                            , Html.br []
                                []
                            , if ((*) -1 <| List.sum (List.map (\u -> u.balance) model.users)) > List.sum (List.map (\t -> t.amount) model.transactions) then
                                Html.div [ Attributes.class "btn btn__yellow" ]
                                    [ Html.text "Falta lana, compa 😱" ]

                              else if List.sum (List.map (\t -> t.amount) model.transactions) < 0 then
                                Html.div [ Attributes.class "btn btn__green", Events.onClick Msg.RegisterTransactions ]
                                    [ Html.text "Terminar" ]

                              else
                                Html.div [ Attributes.class "btn btn__grey" ]
                                    [ Html.text "Terminar" ]
                            ]
                        ]
                    , if List.length model.availableUsers == 0 then
                        Html.div [] []

                      else
                        Html.div [ Attributes.class "new-transaction" ]
                            [ Html.p [ Attributes.class "new-transaction--title" ]
                                [ Html.span [ Attributes.style [ ( "font-size", "20pt" ) ] ]
                                    [ Html.text "💸" ]
                                , Html.text "Registrar transacción de compra"
                                ]
                            , Html.br []
                                []
                            , TransactionRenderer.create model.availableUsers model.transactions model.quantity
                            ]
                    ]
                ]
            ]
        , Html.div [ Attributes.class "col-xs-12  col-sm-12 col-md-5" ]
            [ Html.div [ Attributes.class "card" ]
                [ Html.div [ Attributes.class "card--header" ]
                    [ Html.p [ Attributes.class "card--header-title" ]
                        [ Html.span [ Attributes.style [ ( "font-size", "25pt" ) ] ]
                            [ Html.text "🏦" ]
                        , Html.text "Estado de cuentas"
                        ]
                    , Html.p [ Attributes.class "card--header-subtitle" ]
                        [ Html.text "Aquí puedes ver a quien ajusticiarte 😈 y quien es 😇" ]
                    ]
                , if model.allUsersVisible then
                    Html.div [] (List.indexedMap UserRenderer.display model.users)

                  else
                    Html.div [] (List.indexedMap UserRenderer.display (List.take 8 model.users))
                , if not model.allUsersVisible && List.length model.users > 8 then
                    Html.div [ Attributes.class "card--footer" ]
                        [ Html.p [ Attributes.class "view-more", Events.onClick Msg.ViewAllUsers ]
                            [ Html.text "ver todos" ]
                        ]

                  else
                    Html.div [] []
                ]
            ]
        ]
