SHELL := /bin/bash

configure-server:
	@echo "Configuring the server..." && \
	cp ../configs/server/default/nginx.conf.template ${EXP_DIR}/nginx.conf.template && \
	( set -a && source ${EXP_DIR}/server.env && set +a && envsubst < ${EXP_DIR}/nginx.conf.template > ${EXP_DIR}/nginx.conf && rm ${EXP_DIR}/nginx.conf.template && echo "done" ) && \
	echo "Server configured"
