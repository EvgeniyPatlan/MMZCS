#!/bin/bash

# Generate certificates (ensure key and cert match)
bash ./generate_certs.sh

# Start the server in the background
echo "Starting server..."
./tls_server > server.log 2>&1 &
SERVER_PID=$!
sleep 2  # Give the server time to start

# Check if the server is running
if ! ps -p $SERVER_PID > /dev/null; then
    echo "Server failed to start. Check the server log for details."
    cat server.log
    exit 1
fi

# Run the client and capture its output using expect
echo "Running client..."
./tls_client > client.log 2>&1

# Compare client output with expected output
EXPECTED_OUTPUT="Received: Hello from client!"
ACTUAL_OUTPUT=$(cat client.log | grep "Received:")

if [[ "$ACTUAL_OUTPUT" == "$EXPECTED_OUTPUT" ]]; then
  echo "Test passed!"
else
  echo "Test failed!"
  echo "Expected: $EXPECTED_OUTPUT"
  echo "Actual: $ACTUAL_OUTPUT"
fi

# Kill the server
kill $SERVER_PID

