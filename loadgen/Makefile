SHELL := /bin/bash

PARAMETERS=$(shell jq -r '.parameters[]' ${EXP_DIR}/config/loadgen/loadgen.json)
RUNCFG=$(shell jq -r '.runcfg' ${EXP_DIR}/config/loadgen/loadgen.json)

perform-exp:
	@echo "Performing experiment..."
	BENCHMARK_URL=${BENCHMARK_URL} TOOL=k6 EXPERIMENT_DIR=${EXP_DIR}/metrics/loadgen ./benchmark.sh $(PARAMETERS) ${EXP_DIR}/config/loadgen/script.js && \
	echo "Experiment done"