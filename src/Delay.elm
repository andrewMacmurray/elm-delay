module Delay
    exposing
        ( start
        , State
        , handleSequence
        , after
        )

{-| Utilities to delay updates after a set period of time

# Delay one message
@docs after

# Delay a sequence of messages
@docs State, start, handleSequence

-}

import Process
import Task
import Time exposing (millisecond)


type Phase
    = First
    | Rest


{-|
  Keeps track of the state of the sequence
-}
type State msg
    = State Phase (List ( Float, msg ))


{-|
  Starts the sequence of messages
-}
start : (State msg -> msg) -> List ( Float, msg ) -> msg
start msg msgs =
    msg (State First msgs)


{-|
  Starts the sequence of messages
-}
handleSequence : (State msg -> msg) -> State msg -> (msg -> model -> ( model, Cmd msg )) -> model -> ( model, Cmd msg )
handleSequence sequenceMsg (State phase msgs) update model =
    case phase of
        First ->
            case List.head msgs of
                Just ( ms, msg ) ->
                    model ! [ sequenceDelay ms (State Rest msgs) sequenceMsg ]

                Nothing ->
                    model ! []

        Rest ->
            case List.head msgs of
                Just ( ms, msg ) ->
                    let
                        rest =
                            List.tail msgs |> Maybe.withDefault []

                        ( newModel, cmd ) =
                            update msg model

                        nextCmd =
                            if List.length msgs == 1 then
                                Cmd.none
                            else
                                sequenceDelay ms (State Rest rest) sequenceMsg
                    in
                        newModel ! [ cmd, nextCmd ]

                Nothing ->
                    model ! []


sequenceDelay : Float -> State msg -> (State msg -> msg) -> Cmd msg
sequenceDelay ms (State phase msgs) sequenceMsg =
    Process.sleep (millisecond * ms)
        |> Task.map (always (sequenceMsg (State phase msgs)))
        |> Task.perform identity


{-|
  Starts the sequence of messages
-}
after : Float -> msg -> Cmd msg
after ms msg =
    Process.sleep (millisecond * ms)
        |> Task.map (always msg)
        |> Task.perform identity
