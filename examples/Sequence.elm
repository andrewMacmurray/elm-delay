module Sequence exposing (..)

import Delay
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


type Msg
    = Trigger
    | Red
    | Green
    | Blue
    | Stop
    | Sequence (List ( Float, Msg ))


type alias Model =
    { color : String
    , colorCycling : Bool
    }


init : ( Model, Cmd Msg )
init =
    { color = "blue"
    , colorCycling = False
    }
        ! []


cycleColors : Cmd Msg
cycleColors =
    Delay.start Sequence
        [ ( 2000, Red )
        , ( 2000, Green )
        , ( 2000, Blue )
        , ( 2000, Stop )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Trigger ->
            if not model.colorCycling then
                { model | color = "purple", colorCycling = True } ! [ cycleColors ]
            else
                model ! []

        Red ->
            { model | color = "red" } ! []

        Green ->
            { model | color = "green" } ! []

        Blue ->
            { model | color = "blue" } ! []

        Stop ->
            { model | colorCycling = False } ! []

        Sequence msgs ->
            Delay.handleSequence Sequence msgs update model


view : Model -> Html Msg
view model =
    div
        [ style <| backgroundStyles model
        , onClick Trigger
        ]
        [ text "cycle through the colors" ]


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
