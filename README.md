# Delay

Elm utilities to trigger updates after a delay

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

After triggering `FirstMessage`, update will get called with `SecondMessage` after `500ms`

#### Send a sequence of delayed `Msg`s

To send a sequence of `Msg`s add a new `Msg` type like so:

```elm
type Msg
    = FirstMessage
    | SecondMessage
    | ThirdMessage
    | Sequence (Delay.State Msg) -- add this to your Msg type
```

and add a new branch to your `update` function like so:

```elm
Sequence msgs ->
  Delay.handleSequence Sequence msgs update model
```

This allows a list of `(delay, Msg)` to be funnelled to update by passing them to something like a click handler:

```elm

  div
      [ onClick
          (Delay.start Sequence
              [ ( 1000, FirstMessage )
              , ( 2000, SecondMessage )
              , ( 1000, ThirdMessage )
              ]
          )
      ]
```

Clicking on this div:

+ after `1000ms` update will be called with `FirstMessage`
+ then after `2000ms` update will be called with `SecondMessage`
+ then after `1000ms` update will be called with `ThirdMessage`
