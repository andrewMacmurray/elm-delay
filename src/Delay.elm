module Delay
    exposing
        ( after
        , start
        , handleSequence
        )

{-| Utilities to delay updates after a set period of time

# Delay one message
@docs after

# Delay a sequence of messages
@docs start, handleSequence

-}

import Process
import Task
import Time exposing (millisecond)


{-| Delays an update (with a message) by a given number of milliseconds
-}
after : Float -> msg -> Cmd msg
after ms msg =
    Process.sleep (millisecond * ms)
        |> Task.map (always msg)
        |> Task.perform identity


{-| Starts the sequence of messages
-}
start : (List ( Float, msg ) -> msg) -> List ( Float, msg ) -> Cmd msg
start sequenceMsg msgs =
    let
        firstDelay =
            getDelay 0 msgs
    in
        after firstDelay (sequenceMsg msgs)


{-| Calls update with each message and a delay until finished
-}
handleSequence : (List ( Float, msg ) -> msg) -> List ( Float, msg ) -> (msg -> model -> ( model, Cmd msg )) -> model -> ( model, Cmd msg )
handleSequence sequenceMsg msgs update model =
    case List.head msgs of
        Just ( _, msg ) ->
            let
                remainingMsgs =
                    List.tail msgs |> Maybe.withDefault []

                nextDelay =
                    (getDelay 1) msgs

                ( newModel, cmd ) =
                    update msg model

                nextCmd =
                    if List.length msgs > 1 then
                        after nextDelay (sequenceMsg remainingMsgs)
                    else
                        Cmd.none
            in
                newModel ! [ cmd, nextCmd ]

        Nothing ->
            model ! []


{-| Private, gets a delay value by index from a list of (delay, msg)
-}
getDelay : Int -> List ( Float, msg ) -> Float
getDelay n msgs =
    msgs
        |> List.drop n
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault 0
