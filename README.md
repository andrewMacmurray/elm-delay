# Elm Delay

Elm utilities to trigger updates after a delay

**example**: https://elm-delay-examples.surge.sh/

### Why?

Sometimes you need to trigger updates after a period of time (i.e. to wait for a css transition or animation to complete) or maybe you need to chain a sequence of these updates (for more complex states).

This library provides utilities to express this more tidily.

### How?

#### Send a single delayed `Msg`

To trigger a single update after a period of time pass `Delay.after` as a command to the elm runtime:

```elm
FirstMessage ->
    ( model
    , Delay.after 500 SecondMessage
    )
```

After triggering `FirstMessage`, `500ms` later update will be called with `SecondMessage`

#### Send a sequence of delayed `Msg`s

```elm
Trigger ->
    ( model
    , Delay.sequence
        [ ( 1000, FirstMessage )
        , ( 2000, SecondMessage )
        , ( 1000, ThirdMessage )
        ]
    )
```

by sending a `Trigger` `Msg`:

- after `1000ms` update will be called with `FirstMessage`
- then after `2000ms` update will be called with `SecondMessage`
- then after `1000ms` update will be called with `ThirdMessage`

As a convenience if you'd only like to start a sequence if the model is in a particular shape you can use `Delay.sequenceIf`

```elm
Trigger ->
    ( model
    , Delay.sequenceIf (not model.updating)
        [ ( 1000, FirstMessage )
        , ( 2000, SecondMessage )
        , ( 1000, ThirdMessage )
        ]
    )
```

If you'd like all the steps to have the same unit of time, use the `Delay.withUnit` helper

```elm
Trigger ->
    ( model
    , Delay.sequence 
        Delay.withUnit Delay.seconds
            [ ( 1, FirstMessage )
            , ( 2, SecondMessage )
            , ( 1, ThirdMessage )
            ]
    )
```
