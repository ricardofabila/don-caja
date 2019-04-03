module Renderers.Header exposing (display)

import Html
import Html.Attributes as Attributes


display : Html.Html msg
display =
    Html.div [ Attributes.class "row" ]
        [ Html.div [ Attributes.class "col-12" ]
            [ Html.div [ Attributes.class "text-center" ]
                [ Html.br [] []
                , Html.br [] []
                , Html.img [ Attributes.class "img-responsive text-center", Attributes.style [ ( "margin", "0 auto" ) ], Attributes.src "https://placehold.it/250x160" ]
                    []
                , Html.br [] []
                , Html.br [] []
                , Html.br [] []
                , Html.br [] []
                ]
            ]
        ]
