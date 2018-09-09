port module TestDelay exposing (main)

import Delay
import Platform


port notifyTestRunner : Int -> Cmd msg


port trigger : (() -> msg) -> Sub msg


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


type alias Model =
    Int


type Msg
    = Inc Int
    | Dec Int
    | Trigger ()


testSequence : Cmd Msg
testSequence =
    Delay.sequence <|
        Delay.withUnit Delay.Millisecond <|
            [ ( 500, Inc 5 )
            , ( 500, Inc 5 )
            , ( 500, Inc 5 )
            , ( 500, Dec 15 )
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Trigger _ ->
            ( model, testSequence )

        Inc n ->
            ( model + n, notifyTestRunner <| model + n )

        Dec n ->
            ( model - n, notifyTestRunner <| model - n )


subscriptions : Model -> Sub Msg
subscriptions _ =
    trigger Trigger
