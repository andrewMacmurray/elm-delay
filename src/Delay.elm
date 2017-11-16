module Delay
    exposing
        ( after
        , sequence
        , sequenceIf
        , withUnit
        )

{-| Utilities to delay updates after a set period of time

# Delay one message
@docs after

# Delay a sequence of messages
@docs sequence, sequenceIf, withUnit

-}

import Process
import Task
import Time exposing (Time, millisecond)


{-| Delays an update (with a message) by a given amount of time

    after 500 millisecond DelayedMsg
-}
after : Float -> Time -> msg -> Cmd msg
after time unit msg =
    after_ (time * unit) msg


{-| Private: internal version of after,
    used to collect total time in sequence
-}
after_ : Time -> msg -> Cmd msg
after_ time msg =
    Process.sleep time |> Task.perform (always msg)


{-| Starts a sequence of delayed messages

    sequence
        [ ( 1000, millisecond, FirstMessage )
        , ( 2000, millisecond, SecondMessage )
        , ( 1000, millisecond, ThirdMessage )
        ]
-}
sequence : List ( Float, Time, msg ) -> Cmd msg
sequence msgs =
    msgs
        |> List.foldl collectDelays ( 0, [] )
        |> Tuple.second
        |> Cmd.batch


{-| Private: helps create a list of delays,
    keeps track of the current delay time
-}
collectDelays : ( Float, Time, msg ) -> ( Float, List (Cmd msg) ) -> ( Float, List (Cmd msg) )
collectDelays ( time, unit, msg ) ( previousTotal, cmds ) =
    let
        newTotal =
            addOffset previousTotal time unit
    in
        ( newTotal, cmds ++ [ after_ newTotal msg ] )


{-| Private: checks if consecutive delays are too close together
    applies an offset if they are
-}
addOffset : Float -> Float -> Time -> Float
addOffset previousTotal time unit =
    let
        total =
            previousTotal + (time * unit)
    in
        if total <= previousTotal + 6 then
            total + 6
        else
            total


{-| Starts a sequence of delayed messages if predicate is met

    sequenceIf (not model.updating)
        [ ( 1000, millisecond, FirstMessage )
        , ( 2000, millisecond, SecondMessage )
        , ( 1000, millisecond, ThirdMessage )
        ]
-}
sequenceIf : Bool -> List ( Float, Time, msg ) -> Cmd msg
sequenceIf predicate msgs =
    if predicate then
        sequence msgs
    else
        Cmd.none


{-| Helper for making all steps have the same unit

    sequence <|
        withUnit millisecond
            [ ( 1000, FirstMessage )
            , ( 2000, SecondMessage )
            , ( 1000, ThirdMessage )
            ]
-}
withUnit : Time -> List ( Float, msg ) -> List ( Float, Time, msg )
withUnit unit msgs =
    List.map (\( time, msg ) -> ( time, unit, msg )) msgs
