port module TestDelay exposing (..)

import Delay
import Platform exposing (program)
import Time exposing (millisecond)
import Json.Decode


-- JSON Decode needs to be imported for subscriptions to work
-- https://github.com/elm-lang/core/issues/703


port notifyTestRunner : Int -> Cmd msg


port trigger : (() -> msg) -> Sub msg


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    0 ! []


type alias Model =
    Int


type Msg
    = Inc Int
    | Dec Int
    | Trigger ()


testSequence : Cmd Msg
testSequence =
    Delay.sequence <|
        Delay.withUnit millisecond <|
            [ ( 500, Inc 5 )
            , ( 500, Inc 5 )
            , ( 500, Inc 5 )
            , ( 500, Dec 15 )
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Trigger _ ->
            model ! [ testSequence ]

        Inc n ->
            (model + n) ! [ notifyTestRunner <| model + n ]

        Dec n ->
            (model - n) ! [ notifyTestRunner <| model - n ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    trigger Trigger
