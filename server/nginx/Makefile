setup:
	../../install.sh setup_server

clean:
	@echo "Clearing NGINX cache..."
	@sudo rm -rf /path/to/nginx/cache/*
	@echo "Flushing access and error logs..."
	@sudo truncate -s 0 /var/log/nginx/access.log
	@sudo truncate -s 0 /var/log/nginx/error.log
	@echo "Restarting NGINX..."
	@sudo systemctl restart nginx
	@echo "All clean for new benchmarking!"