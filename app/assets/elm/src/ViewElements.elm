module ViewElements exposing (button)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


button cfg =
    Input.button
        [ Border.color (rgb255 0 105 217)
        , Border.width 1
        , Border.rounded 4
        , paddingXY 10 2
        , Font.bold
        , Font.color (rgb255 0 105 217)
        , Font.size 12
        , Font.letterSpacing 1
        , mouseOver
            [ Border.color (rgb255 100 100 100)
            , Font.color (rgb255 100 100 100)
            ]
        ]
        { onPress = Just cfg.onPress
        , label = row [ spacing 4 ] [ cfg.icon [], text (String.toUpper cfg.label) ]
        }
