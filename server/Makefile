SHELL := /bin/bash

clear-nginx-cache:
	@echo "Clearing NGINX cache..."
	@sudo rm -rf /path/to/nginx/cache/*
	@echo "Flushing access and error logs..."
	@sudo truncate -s 0 /var/log/nginx/access.log
	@sudo truncate -s 0 /var/log/nginx/error.log

configure-server:
	$(MAKE) clear-nginx-cache 
	@echo "Configuring the server..." && \
	mkdir -p ${EXP_DIR}/config/server && \
	cp ../configs/server/default/nginx.conf.template ${EXP_DIR}/config/server/nginx.conf.template && \
	( set -a && source ${EXP_DIR}/config/server/server.env && set +a && envsubst < ${EXP_DIR}/config/server/nginx.conf.template > ${EXP_DIR}/config/server/nginx.conf && rm ${EXP_DIR}/config/server/nginx.conf.template && echo "done" ) && \
	sudo cp ${EXP_DIR}/config/server/nginx.conf /etc/nginx/nginx.conf && \
	echo "checking nginx configuration..." && \
	sudo nginx -t && \
	echo "restarting nginx..." && \
	sudo systemctl restart nginx && \
	echo "Server configured"

benchmark-server:
	@echo "Benchmarking the server..." 
	nohup ./netcat.sh nc_listen > /dev/null 2>&1 & 
	EXPERIMENT_DIR=${EXP_DIR} nohup ./benchmark.sh ${PARAMETERS} > /dev/null 2>&1 &
	echo "Server benchmarking started"
