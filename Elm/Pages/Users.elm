module Pages.Users exposing (display)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Input.Number
import Models.User as User exposing (..)
import Msg exposing (..)
import Renderers.User as UserRenderer


display : List User -> String -> Int -> String -> Html.Html Msg
display users newUserName newUserBalance creatingUser =
    Html.div [ Attributes.class "row" ]
        [ Html.div [ Attributes.class "col-xs-12 col-md-offset-2 col-md-8" ]
            [ Html.div [ Attributes.class "card" ]
                [ Html.div [ Attributes.class "card--header" ]
                    [ Html.p [ Attributes.class "card--header-title" ]
                        [ Html.span [ Attributes.style [ ( "font-size", "25pt" ) ] ]
                            [ Html.text "👶 " ]
                        , Html.text " Nuevo usuario"
                        ]
                    , Html.p [ Attributes.class "card--header-subtitle" ]
                        [ Html.text "Aquí añadir un nuevo usuario al sistema." ]
                    ]
                , Html.div [] (List.indexedMap UserRenderer.display users)
                , Html.div [ Attributes.class "card--footer" ]
                    [ Html.div
                        [ Attributes.class "new-transaction" ]
                        [ Html.p [ Attributes.class "new-transaction--title" ]
                            [ Html.text "Registar un nuevo usuario"
                            ]
                        , Html.br []
                            []
                        , Html.div [ Attributes.class "pure-form" ]
                            [ Html.div [ Attributes.class "new-transaction-register" ]
                                [ Html.div [ Attributes.class "new-transaction-register-user" ]
                                    [ Html.input [ Attributes.placeholder "usuario", Attributes.type_ "text", Attributes.style [ ( "width", "100%" ) ], Attributes.value newUserName, Events.onInput Msg.SetNewUserName ] []
                                    ]
                                , Html.div [ Attributes.class "new-transaction-register-amount" ]
                                    [ Input.Number.input
                                        (Input.Number.Options
                                            -- maxLength
                                            (Just 4)
                                            -- maxValue
                                            (Just 150)
                                            -- minValue
                                            (Just 0)
                                            -- onInput
                                            Msg.SetNewUserBalance
                                            -- hasFocus
                                            Nothing
                                        )
                                        [ Attributes.class "form-control" ]
                                        (Just newUserBalance)
                                    ]
                                , if creatingUser == "loading" then
                                    Html.div [ Attributes.class "new-transaction-register-button new-transaction-register-button-yellow" ]
                                        [ Html.text "Creando" ]

                                  else if creatingUser == "" then
                                    Html.div [ Attributes.class "new-transaction-register-button", Events.onClick Msg.CreateNewUser ]
                                        [ Html.text "Crear Usuario" ]

                                  else
                                    Html.div [ Attributes.class "new-transaction-register-button new-transaction-register-button-reds" ]
                                        [ Html.text "Error Inesperado" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
