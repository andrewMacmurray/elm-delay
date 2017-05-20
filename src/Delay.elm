module Delay
    exposing
        ( after
        , start
        , startIf
        , handleSequence
        )

{-| Utilities to delay updates after a set period of time

# Delay one message
@docs after

# Delay a sequence of messages
@docs start, startIf, handleSequence

-}

import Process
import Task
import Time exposing (millisecond)


{-| Delays an update (with a message) by a given number of milliseconds

    -- triggers DelayedMsg after 500ms
    after 500 DelayedMsg
-}
after : Float -> msg -> Cmd msg
after ms msg =
    Process.sleep (millisecond * ms)
        |> Task.map (always msg)
        |> Task.perform identity


{-| Starts a sequence of messages given the SequenceMsg and a list of messages to be sent

    type Msg
        = FirstMsg
        | SecondMsg
        | ThirdMsg
        | Sequence (List ( Float, Msg ))

    -- triggers each Msg one after the other with a 500ms delay
    start Sequence
      [ (500, FirstMsg)
      , (500, SecondMsg)
      , (500, ThirdMsg)
      ]
-}
start : (List ( Float, msg ) -> msg) -> List ( Float, msg ) -> Cmd msg
start sequenceMsg msgs =
    startIf True sequenceMsg msgs


{-| Starts a sequence if a predicate value is True. This is helpful if you'd like to start the sequence only if your model is in a particular shape

    startIf (not model.updating) Sequence
      [ (500, FirstMsg)
      , (500, SecondMsg)
      , (500, ThirdMsg)
      ]
-}
startIf :
    Bool
    -> (List ( Float, msg ) -> msg)
    -> List ( Float, msg )
    -> Cmd msg
startIf predicate sequenceMsg msgs =
    if predicate then
        let
            firstDelay =
                getDelay 0 msgs
        in
            after firstDelay (sequenceMsg msgs)
    else
        Cmd.none


{-| Calls update with each message and a delay until finished.

    -- recursively calls update until all Msgs have been processed
    Sequence msgs ->
      handleSequence Sequence update model
-}
handleSequence :
    (List ( Float, msg ) -> msg)
    -> List ( Float, msg )
    -> (msg -> model -> ( model, Cmd msg ))
    -> model
    -> ( model, Cmd msg )
handleSequence sequenceMsg msgs update model =
    case List.head msgs of
        Just ( _, msg ) ->
            let
                remainingMsgs =
                    List.drop 1 msgs

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
