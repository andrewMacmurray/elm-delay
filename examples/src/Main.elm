module Main exposing (main)

import Browser
import Delay
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)



-- Model


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



-- Init


init : ( Model, Cmd Msg )
init =
    ( { color = "#1E70B5"
      , colorCycling = False
      }
    , Cmd.none
    )



-- Sequence


cycleColors : Model -> Cmd Msg
cycleColors model =
    Delay.sequenceIf (not model.colorCycling)
        (Delay.withUnit Delay.Millisecond
            [ ( 0, ColorCycling True )
            , ( 0, Red )
            , ( 2000, Green )
            , ( 2000, Blue )
            , ( 2000, ColorCycling False )
            ]
        )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Trigger ->
            ( model, cycleColors model )

        Red ->
            ( { model | color = "#BC1F31" }, Cmd.none )

        Green ->
            ( { model | color = "#259860" }, Cmd.none )

        Blue ->
            ( { model | color = "#1E70B5" }, Cmd.none )

        ColorCycling bool ->
            ( { model | colorCycling = bool }, Cmd.none )



-- View


view : Model -> Html Msg
view { color } =
    div
        [ style "background-color" color
        , class "background"
        , onClick Trigger
        ]
        [ text "click to cycle through the colors" ]



-- App


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
