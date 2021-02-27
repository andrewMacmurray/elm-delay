port module Main exposing (main)

import Delay
import Platform



-- Model


type alias Model =
    ()


type Msg
    = Output Output
    | Done


type alias Flags =
    List Input


type alias Input =
    { delay : Float
    , value : Output
    }


type alias Output =
    Int



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( ()
    , runSequence flags
    )



-- Sequence


runSequence : Flags -> Cmd Msg
runSequence inputs =
    Delay.sequence (Delay.withUnit Delay.Millisecond (toSequence inputs))


toSequence : List Input -> List ( Float, Msg )
toSequence inputs =
    List.map (\input -> ( input.delay, Output input.value )) inputs ++ [ ( 0, Done ) ]



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Output n ->
            ( model, output n )

        Done ->
            ( model, done () )



-- Program


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = always Sub.none
        }



-- Ports


port output : Output -> Cmd msg


port done : () -> Cmd msg
