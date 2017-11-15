port module TestDelay exposing (..)

import Delay
import Platform exposing (program)
import Time exposing (millisecond)


port notifyTestRunner : Int -> Cmd msg


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    update Trigger 0


type alias Model =
    Int


type Msg
    = Inc Int
    | Dec Int
    | Trigger


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
        Trigger ->
            model ! [ testSequence, notifyTestRunner model ]

        Inc n ->
            (model + n) ! [ notifyTestRunner <| model + n ]

        Dec n ->
            (model - n) ! [ notifyTestRunner <| model - n ]
