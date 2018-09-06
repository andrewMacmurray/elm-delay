port module TestDelay exposing (Model, Msg(..), init, main, notifyTestRunner, subscriptions, testSequence, trigger, update)

import Delay
import Json.Decode
import Platform exposing (worker)



-- JSON Decode needs to be imported for subscriptions to work
-- https://github.com/elm-lang/core/issues/703


port notifyTestRunner : Int -> Cmd msg


port trigger : (() -> msg) -> Sub msg


main : Program () Model Msg
main =
    worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0
    , Cmd.none
    )


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
            ( model
            , testSequence
            )

        Inc n ->
            ( model + n
            , notifyTestRunner <| model + n
            )

        Dec n ->
            ( model - n
            , notifyTestRunner <| model - n
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    trigger Trigger
