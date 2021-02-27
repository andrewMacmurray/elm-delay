module Delay exposing
    ( after
    , sequence, sequenceIf, withUnit
    , Millis, seconds, minutes, hours
    )

{-| Utilities to delay updates after a given number of milliseconds


# Delay one message

@docs after


# Delay a sequence of messages

@docs sequence, sequenceIf, withUnit


# Time units

@docs Millis, seconds, minutes, hours

-}

import Process
import Task


{-| Default unit of time
-}
type alias Millis =
    Int


{-| Triggers a Message after given number of milliseconds

    after 500 DelayedMsg

-}
after : Millis -> msg -> Cmd msg
after time msg =
    Process.sleep (toFloat time) |> Task.perform (always msg)


{-| Start a sequence of delayed Messages

this can be read as:

  - after `1000ms` `FirstMessage` will be triggered
  - then after `2000ms` `SecondMessage` will be triggered
  - then after `1000ms` `ThirdMessage` will be triggered

```
sequence
    [ ( 1000, FirstMessage )
    , ( 2000, SecondMessage )
    , ( 1000, ThirdMessage )
    ]
```

-}
sequence : List ( Millis, msg ) -> Cmd msg
sequence =
    List.foldl collectDelays ( 0, [] )
        >> Tuple.second
        >> Cmd.batch


collectDelays : ( Millis, msg ) -> ( Millis, List (Cmd msg) ) -> ( Millis, List (Cmd msg) )
collectDelays ( time, msg ) ( previousTotal, cmds ) =
    let
        newTotal =
            addOffset previousTotal time
    in
    ( newTotal, cmds ++ [ after newTotal msg ] )


{-| checks if consecutive delays are too close together
applies an offset if they are
-}
addOffset : Millis -> Millis -> Millis
addOffset previousTotal time =
    let
        total =
            previousTotal + time
    in
    if total <= previousTotal + 6 then
        total + 6

    else
        total


{-| Convert `milliseconds` to `seconds`
-}
seconds : Millis -> Millis
seconds millis =
    millis * 1000


{-| Convert `milliseconds` to `minutes`
-}
minutes : Millis -> Millis
minutes millis =
    seconds millis * 60


{-| Convert `milliseconds` to `hours`
-}
hours : Millis -> Millis
hours millis =
    minutes millis * 60


{-| Conditionally start a sequence of delayed Messages

    sequenceIf (not model.updating)
        [ ( 1000, FirstMessage )
        , ( 2000, SecondMessage )
        , ( 1000, ThirdMessage )
        ]

-}
sequenceIf : Bool -> List ( Millis, msg ) -> Cmd msg
sequenceIf predicate msgs =
    if predicate then
        sequence msgs

    else
        Cmd.none


{-| Helper for making all steps have the same unit

    sequence
        (withUnit seconds
            [ ( 1, FirstMessage )
            , ( 2, SecondMessage )
            , ( 1, ThirdMessage )
            ]
        )

-}
withUnit : (Millis -> Millis) -> List ( Millis, msg ) -> List ( Millis, msg )
withUnit toUnit =
    List.map (Tuple.mapFirst toUnit)
