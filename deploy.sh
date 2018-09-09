EXAMPLES_DOMAIN="wakeful-treatment.surge.sh"
TESTS_DOMAIN="near-pie.surge.sh"

# deploy examples to surge
echo "deploying examples"
cd examples
elm make Sequence.elm --output=elm.js --debug
surge --domain $EXAMPLES_DOMAIN --project ./

# deploy integration tests to surge
echo "deploying tests"
cd ../tests
elm make TestDelay.elm --output=elm.js --debug
surge --domain $TESTS_DOMAIN --project ./

echo "done"
