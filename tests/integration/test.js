const test = require("ava");
const { Elm } = require("../program");

function runSequence(sequence) {
  let outputs = [];

  return new Promise((resolve) => {
    const app = Elm.Main.init({ flags: sequence });
    app.ports.output.subscribe(addToOutputs);
    app.ports.done.subscribe(() => resolve(outputs));
  });

  function addToOutputs(value) {
    outputs.push({ value: value, time: Date.now() });
  }
}

test("emits values in sequence", async (t) => {
  const sequence = [
    { delay: 100, value: 1 },
    { delay: 100, value: 2 },
    { delay: 100, value: 3 },
    { delay: 100, value: 4 },
    { delay: 100, value: 5 },
  ];

  const output = await runSequence(sequence);

  t.deepEqual(valuesFrom(sequence), valuesFrom(output));
});

test("delays each value by given interval", async (t) => {
  const start = Date.now();

  const sequence = [
    { delay: 100, value: 1 },
    { delay: 200, value: 2 },
    { delay: 100, value: 3 },
    { delay: 200, value: 4 },
    { delay: 100, value: 5 },
  ];

  const output = await runSequence(sequence);

  assertDelayedBy(100, output[0].time, start, t);
  assertDelayedBy(300, output[1].time, start, t);
  assertDelayedBy(400, output[2].time, start, t);
  assertDelayedBy(600, output[3].time, start, t);
  assertDelayedBy(700, output[4].time, start, t);
});

function assertDelayedBy(expectedDifference, time, start, t) {
  const difference = time - start;
  t.true(
    isCloseTo(expectedDifference, difference),
    `Must be within range ${expectedDifference}: actual: ${difference}`
  );
}

function isCloseTo(n, value) {
  const tolerance = 5;
  return value <= n + tolerance && value >= n - tolerance;
}

function valuesFrom(sequence) {
  return sequence.map((x) => x.value);
}
