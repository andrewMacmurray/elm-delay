# Delay

Elm utilities to trigger updates after a delay

example: https://andrewmacmurray.github.io/elm-delay/

### Why?

Sometimes you need to trigger updates after a period of time (i.e. to wait for a css transition or animation to complete) or maybe you need to chain a sequence of these updates (for more complex states).

This library aims for a cleaner way to express this.

### How?

#### Send a single delayed `Msg`

To trigger a single update after a period of time (in milliseconds) pass `Delay.after` as a command to the elm runtime:

```elm
FirstMessage ->
    model ! [ Delay.after 500 SecondMessage ]
```

After triggering `FirstMessage`, `500ms` later update will be called with `SecondMessage`

#### Send a sequence of delayed `Msg`s

To send a sequence of `Msg`s add a new `Msg` type like so:

```elm
type Msg
    = Trigger
    | FirstMessage
    | SecondMessage
    | ThirdMessage
    | Sequence (List (Float, Msg)) -- add this to your Msg type
```

and add a new branch to your `update` function like so:

```elm
Sequence msgs ->
  Delay.handleSequence Sequence msgs update model
```

This allows a list of `(delay, Msg)` to be funnelled to update by passing them as a command to the elm runtime like so:

```elm

Trigger ->
    model
        ! [ Delay.start Sequence
                [ ( 1000, FirstMessage )
                , ( 2000, SecondMessage )
                , ( 1000, ThirdMessage )
                ]
          ]
```

by sending a `Trigger` `Msg`:

+ after `1000ms` update will be called with `FirstMessage`
+ then after `2000ms` update will be called with `SecondMessage`
+ then after `1000ms` update will be called with `ThirdMessage`


As a convenience if you'd only like to start a sequence if the model is in a particular shape you can use `Delay.startIf`

```elm

Trigger ->
    model
        ! [ Delay.startIf (not model.updating) Sequence
                [ ( 1000, FirstMessage )
                , ( 2000, SecondMessage )
                , ( 1000, ThirdMessage )
                ]
          ]
```
