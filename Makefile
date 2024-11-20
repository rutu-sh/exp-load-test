SHELL := /bin/bash

CL_DIR=${CURDIR}/.cloudlab
TOOLS_SRC_DIR=${CURDIR}/setup/cloudlab-tools
BENCHMARK_URL=http://192.168.1.2

EXP_DIR=${CURDIR}/experiments/${EXP_NAME}

include setup/cloudlab-tools/cloudlab_tools.mk


# Cloudlab parameters
LOAD_GEN_NODE=NODE_0
SERVER_NODE=NODE_1
REMOTE_DIR=/users/${CLOUDLAB_USERNAME}/src
REMOTE_SUBDIR=$(shell basename ${CURDIR})
PROJ_ROOT_DIR="${REMOTE_DIR}/${REMOTE_SUBDIR}"


sync-code-to-nodes:
	@echo "Syncing code to the nodes..."
	$(MAKE) cl-sync-code NODE=${LOAD_GEN_NODE} && \
	$(MAKE) cl-sync-code NODE=${SERVER_NODE} && \
	echo "Code synced to the nodes"


setup-loadgen-node:
	@echo "Setting up the load generator node..."
	$(MAKE) cl-sync-code NODE=$(LOAD_GEN_NODE) && \
	$(MAKE) cl-run-cmd NODE=$(LOAD_GEN_NODE) COMMAND="cd ${REMOTE_DIR}/exp-load-test && ./install.sh setup_loadgen" && \
	echo "Load generator node setup done"

setup-server-node:
	@echo "Setting up the server node..."
	$(MAKE) cl-sync-code NODE=${SERVER_NODE} && \
	$(MAKE) cl-run-cmd NODE=${SERVER_NODE} COMMAND="cd ${REMOTE_DIR}/exp-load-test/server/nginx && make setup" && \
	echo "Server node setup done"

setup-platform:
	@echo "Setting up the platform..."
	$(MAKE) setup-server-node && \
	$(MAKE) setup-loadgen-node && \
	echo "Platform setup done"

copy-all-exp-from-loadgen:
	@echo "Copying all experiments from the loadgen..."
	$(MAKE) cl-scp-from-host NODE=${LOAD_GEN_NODE} SCP_SRC=$(REMOTE_DIR)/exp-load-test/experiments SCP_DEST=${CURDIR} && \
	echo "All experiments copied from the loadgen"

copy-exp-data:
	echo $(REMOTE_DIR)
	@echo "Copying experiment data..." && \
	$(MAKE) cl-scp-from-host NODE=$(SERVER_NODE) SCP_SRC=$(REMOTE_DIR)/exp-load-test/experiments/${EXP_NAME} SCP_DEST=${CURDIR}/experiments && \
	$(MAKE) cl-scp-from-host NODE=$(LOAD_GEN_NODE) SCP_SRC=$(REMOTE_DIR)/exp-load-test/experiments/${EXP_NAME} SCP_DEST=${CURDIR}/experiments && \
	echo "Experiment data copied"

gen-exp-config:
	@echo "Generating experiment configuration..." && \
	./scripts/exp.sh create_exp_context ${EXP_NAME} ${EXP_DIR} ${CURDIR} && \
	echo "Experiment configuration generated"


# call after gen-exp-config
configure-server: 
	@echo "Configuring server..." && \
	$(MAKE) cl-sync-code NODE=${SERVER_NODE} && \
	$(MAKE) cl-run-cmd NODE=${SERVER_NODE} COMMAND="cd ${REMOTE_DIR}/exp-load-test/server && make configure-server EXP_NAME=${EXP_NAME} EXP_DIR=${REMOTE_DIR}/${REMOTE_SUBDIR}/experiments/${EXP_NAME}" && \
	echo "Server configured"

run-exp: 
	@echo "Running experiment ${EXP_NAME}..." && \
	$(MAKE) gen-exp-config && \
	$(MAKE) configure-server && \
	$(MAKE) sync-code-to-nodes && \
	$(MAKE) cl-run-cmd NODE=${SERVER_NODE} COMMAND="cd ${REMOTE_DIR}/exp-load-test/server && make benchmark-server EXP_DIR=${REMOTE_DIR}/${REMOTE_SUBDIR}/experiments/${EXP_NAME}" > /dev/null 2>&1 &
	$(MAKE) cl-run-cmd NODE=${LOAD_GEN_NODE} COMMAND="cd ${REMOTE_DIR}/exp-load-test/loadgen && make perform-exp BENCHMARK_URL=${BENCHMARK_URL} EXP_DIR=${REMOTE_DIR}/${REMOTE_SUBDIR}/experiments/${EXP_NAME}" && \
	$(MAKE) copy-exp-data && \
	echo "Experiment ${EXP_NAME} done"