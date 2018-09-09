module Delay exposing
    ( TimeUnit(..)
    , after
    , sequence, sequenceIf, withUnit
    )

{-| Utilities to delay updates after a set period of time

@docs TimeUnit


# Delay one message

@docs after


# Delay a sequence of messages

@docs sequence, sequenceIf, withUnit

-}

import Process
import Task


type Duration
    = Duration Float TimeUnit


{-| Standard units of time
-}
type TimeUnit
    = Millisecond
    | Second
    | Minute
    | Hour


{-| Delays an update (with a message) by a given amount of time

    after 500 Millisecond DelayedMsg

-}
after : Float -> TimeUnit -> msg -> Cmd msg
after time unit msg =
    after_ (toMillis <| Duration time unit) msg


toMillis : Duration -> Float
toMillis (Duration t u) =
    case u of
        Millisecond ->
            t

        Second ->
            1000 * t

        Minute ->
            toMillis <| Duration (60 * t) Second

        Hour ->
            toMillis <| Duration (60 * t) Minute


{-| Private: internal version of after,
used to collect total time in sequence
-}
after_ : Float -> msg -> Cmd msg
after_ time msg =
    Process.sleep time |> Task.perform (always msg)


{-| Starts a sequence of delayed messages

    sequence
        [ ( 1000, Millisecond, FirstMessage )
        , ( 2000, Millisecond, SecondMessage )
        , ( 1000, Millisecond, ThirdMessage )
        ]

-}
sequence : List ( Float, TimeUnit, msg ) -> Cmd msg
sequence msgs =
    msgs
        |> List.foldl collectDelays ( 0, [] )
        |> Tuple.second
        |> Cmd.batch


{-| Private: helps create a list of delays,
keeps track of the current delay time
-}
collectDelays : ( Float, TimeUnit, msg ) -> ( Float, List (Cmd msg) ) -> ( Float, List (Cmd msg) )
collectDelays ( time, unit, msg ) ( previousTotal, cmds ) =
    let
        newTotal =
            addOffset previousTotal time unit
    in
    ( newTotal, cmds ++ [ after_ newTotal msg ] )


{-| Private: checks if consecutive delays are too close together
applies an offset if they are
-}
addOffset : Float -> Float -> TimeUnit -> Float
addOffset previousTotal time unit =
    let
        total =
            previousTotal + (toMillis <| Duration time unit)
    in
    if total <= previousTotal + 6 then
        total + 6

    else
        total


{-| Starts a sequence of delayed messages if predicate is met

    sequenceIf (not model.updating)
        [ ( 1000, Millisecond, FirstMessage )
        , ( 2000, Millisecond, SecondMessage )
        , ( 1000, Millisecond, ThirdMessage )
        ]

-}
sequenceIf : Bool -> List ( Float, TimeUnit, msg ) -> Cmd msg
sequenceIf predicate msgs =
    if predicate then
        sequence msgs

    else
        Cmd.none


{-| Helper for making all steps have the same unit

    sequence <|
        withUnit Millisecond
            [ ( 1000, FirstMessage )
            , ( 2000, SecondMessage )
            , ( 1000, ThirdMessage )
            ]

-}
withUnit : TimeUnit -> List ( Float, msg ) -> List ( Float, TimeUnit, msg )
withUnit unit msgs =
    List.map (\( time, msg ) -> ( time, unit, msg )) msgs
