#!/bin/bash

# Usage: ./terminate_on_request.sh <port> <pid>
# Example: ./terminate_on_request.sh 8080 12345

PORT=30000

if [[ -z "$PORT" ]]; then
    echo "Usage: $0 <port>"
    exit 1
fi

# Ensure nc is available
if ! command -v nc &> /dev/null; then
    echo "Error: nc (netcat) is required but not installed."
    exit 1
fi

echo "Listening on port $PORT for a termination request..."

# Start a simple listener
nc -d -l -p "$PORT" | while read line; do
    if [ "$line" = "BENCHMARKING_END" ]; then
        pids=$(pgrep -f "./benchmark.sh" | tr '\n' ' ')
        echo "Terminating all processes with pids: $pids"
        kill -TERM $pids
        exit 0
    fi
done > /dev/null &

NC_PID=$!
wait $NC_PID