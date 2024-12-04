#!/bin/bash

# Usage: ./terminate_on_request.sh <port> <pid>
# Example: ./terminate_on_request.sh 8080 12345

if [[ -z "$PORT" ]]; then
    echo "Usage: $0 <port>"
    exit 1
fi

function nc_listen {
    local port=30000

    if ! command -v nc &> /dev/null; then
        echo "Error: nc (netcat) is required but not installed."
        exit 1
    fi

    echo "Listening on port $port for a termination request..."
    nc -d -l -p "$port" | while read line; do
        if [ "$line" = "BENCHMARKING_END" ]; then
            pids=$(pgrep -f "./benchmark.sh" | tr '\n' ' ')
            echo "Terminating all processes with pids: $pids"
            kill -TERM $pids
            nc_pid=$(pgrep -f "nc -d -l -p $port")
            echo "Terminating the listener with pid: $nc_pid"
            kill -TERM $nc_pid
        fi
    done > /dev/null &
}

"$@"