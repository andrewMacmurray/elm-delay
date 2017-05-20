module Sequence exposing (..)

import Delay
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


type alias Model =
    { color : String
    , colorCycling : Bool
    }


type Msg
    = Trigger
    | Red
    | Green
    | Blue
    | ColorCycling Bool
    | Sequence (List ( Float, Msg ))


init : ( Model, Cmd Msg )
init =
    { color = "#1E70B5"
    , colorCycling = False
    }
        ! []


cycleColors : Model -> Cmd Msg
cycleColors model =
    let
        sequence =
            Delay.startIf (not model.colorCycling) Sequence
    in
        sequence
            [ ( 0, ColorCycling True )
            , ( 0, Red )
            , ( 2000, Green )
            , ( 2000, Blue )
            , ( 2000, ColorCycling False )
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Trigger ->
            model ! [ cycleColors model ]

        Red ->
            { model | color = "#BC1F31" } ! []

        Green ->
            { model | color = "#259860" } ! []

        Blue ->
            { model | color = "#1E70B5" } ! []

        ColorCycling bool ->
            { model | colorCycling = bool } ! []

        Sequence msgs ->
            Delay.handleSequence Sequence msgs update model


view : Model -> Html Msg
view model =
    div
        [ style <| backgroundStyles model
        , onClick Trigger
        ]
        [ text "click to cycle through the colors" ]


backgroundStyles : Model -> List ( String, String )
backgroundStyles { color } =
    [ ( "background-color", color )
    , ( "position", "fixed" )
    , ( "width", "100%" )
    , ( "height", "100%" )
    , ( "top", "0" )
    , ( "left", "0" )
    , ( "transition", "2s ease" )
    , ( "display", "flex" )
    , ( "justify-content", "center" )
    , ( "align-items", "center" )
    , ( "text-align", "center" )
    , ( "color", "white" )
    , ( "cursor", "pointer" )
    , ( "font-family", "helvetica" )
    , ( "font-size", "2rem" )
    ]


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
