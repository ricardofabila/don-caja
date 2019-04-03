module Renderers.Footer exposing (display)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Models.Page as Page
import Msg exposing (..)


display : Page.Page -> Html.Html Msg
display currentPage =
    let
        activeStyle =
            Attributes.style [ ( "opacity", "1" ) ]

        cartActiveClass =
            case currentPage of
                Page.Cart ->
                    activeStyle

                _ ->
                    Attributes.style [ ( "opacity", "0.5" ) ]

        depositsActiveClass =
            case currentPage of
                Page.Deposits ->
                    activeStyle

                _ ->
                    Attributes.style [ ( "opacity", "0.5" ) ]

        usersActiveClass =
            case currentPage of
                Page.Users ->
                    activeStyle

                _ ->
                    Attributes.style [ ( "opacity", "0.5" ) ]
    in
    Html.footer []
        [ Html.div [ usersActiveClass, Attributes.class "footer--button", Events.onClick <| Msg.ChangePage Page.Users ]
            [ Html.span [ Attributes.style [ ( "font-size", "45pt" ) ] ]
                [ Html.text "\x1F9D4\x1F3FB👩\x1F3FC" ]
            , Html.br []
                []
            , Html.text
                "Usuarios"
            ]
        , Html.div [ cartActiveClass, Attributes.class "footer--button", Events.onClick <| Msg.ChangePage Page.Cart ]
            [ Html.span [ Attributes.style [ ( "font-size", "45pt" ) ] ]
                [ Html.text "\x1F6D2" ]
            , Html.br []
                []
            , Html.text
                "Compras"
            ]
        , Html.div [ depositsActiveClass, Attributes.class "footer--button", Events.onClick <| Msg.ChangePage Page.Deposits ]
            [ Html.span [ Attributes.style [ ( "font-size", "45pt" ) ] ]
                [ Html.text "💵" ]
            , Html.br []
                []
            , Html.text
                "Abonos"
            ]
        ]
