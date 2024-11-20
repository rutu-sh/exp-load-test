#!/bin/bash

set -eEuo pipefail

function cleanup {
    echo "Cleaning up..."
    rm -f $CPU_F $MEM_F 
}

trap 'last_command=$BASH_COMMAND; signal_received="EXIT"; cleanup; exit 0' EXIT
trap 'last_command=$BASH_COMMAND; signal_received="INT"; trap - INT; cleanup; kill -INT $$' INT
trap 'last_command=$BASH_COMMAND; signal_received="TERM"; trap - TERM; cleanup; kill -TERM $$' TERM
trap 'last_command=$BASH_COMMAND; signal_received="ERR"; cleanup; exit 1' ERR


exp_dir="${EXPERIMENT_DIR}/metrics/server"
mkdir -p "${exp_dir}"

# create files to store the metrics of the experiment
CPU_F=$(mktemp)
MEM_F=$(mktemp)
LOG_F=$(mktemp)
OUT_F="${exp_dir}/results.csv"


TOOL_NAME=${TOOL_NAME:-"nginx"}

# start the monitoring process
echo "Monitoring $TOOL_NAME..."

S_INT=${S_INT:-1}

echo "CPU file: $CPU_F"
echo "MEM file: $MEM_F"
echo "LOG file: $LOG_F"


echo "TIMESTAMP,CPU,MEM" > ${OUT_F}

while true; do
    
    pids=()

    all_tool_pids=$(pgrep -f "${TOOL_NAME}")
    if [ -z "$all_tool_pids" ]; then
        echo "No process found for $TOOL_NAME"
        exit 1
    fi
    
    # get the CPU and MEM usage of the tool
    {
        exec > "${CPU_F}" 2>> "${LOG_F}";
        all_tool_pids=$(pgrep -f "${TOOL_NAME}")
        pid_array=($all_tool_pids)
        n_pids=${#pid_array[@]}
        chunk_size=10
        total_sum=0
        chunk_sums=()
        chunk_sum_file=$(mktemp)

        for((i=0; i< ${n_pids}; i+=${chunk_size})); do
            {
                chunk=${pid_array[@]:i:chunk_size}
                chunk_sum=$(sudo top -b -n 2 -d "${S_INT}" -p $(echo ${chunk} | tr ' ' ',') | awk '/PID USER/{last_line_found=1; next} last_line_found && /nginx/ { sum += $9 } END { print sum }';)
                if [ -z "$chunk_sum" ]; then
                    chunk_sum=0
                fi
                echo $chunk_sum >> $chunk_sum_file
            } &
        done

        wait

        while read line; do
            total_sum=$(echo "$total_sum + $line" | bc)
        done < $chunk_sum_file

        echo $total_sum
    } &
    pids+=($!)

    {
        exec > "$MEM_F" 2>> "${LOG_F}";
        all_tool_pids=$(pgrep -f "${TOOL_NAME}" | tr '\n' '|' | sed 's/|$//')
        sudo smem -H -c 'pid pss' -P "${TOOL_NAME}" | { grep -E "${all_tool_pids}" || echo 0; } | awk '{sum += $2} END {print sum}'; 
    } &
    pids+=($!)

    trap - EXIT
    trap - INT
    trap - TERM
    trap - ERR

    wait "${pids[@]}"
    waitstatus=$?
    if [ $waitstatus -ne 0 ]; then
        echo "Error collecting metrics"
        exit 1
    fi

    trap 'last_command=$BASH_COMMAND; signal_received="ERR"; cleanup; exit 1' ERR
    trap 'last_command=$BASH_COMMAND; signal_received="TERM"; trap - TERM; cleanup; kill -TERM $$' TERM
    trap 'last_command=$BASH_COMMAND; signal_received="INT"; trap - INT; cleanup; kill -INT $$' INT
    trap 'last_command=$BASH_COMMAND; signal_received="EXIT"; cleanup; exit 0' EXIT

    # get the timestamp
    timestamp=$(date +%s)
    cpu_usage=$(cat "${CPU_F}")
    mem_usage=$(cat "${MEM_F}")

    echo "$timestamp,$cpu_usage,$mem_usage" >> ${OUT_F}

done