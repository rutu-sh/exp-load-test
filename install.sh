#!/bin/bash

function install_k6 {
    sudo gpg -k
    sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
    echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
    sudo apt-get update
    sudo apt-get install k6
}

function install_nginx {
    sudo apt-get install -y nginx
}

function install_benchmark_tools {
    sudo apt-get update -y && sudo apt-get install -y smem jq iftop ifstat ethtool
}

function setup_loadgen {
    install_benchmark_tools
    install_k6
}

function setup_server {
    install_benchmark_tools
    install_nginx
}


"$@"