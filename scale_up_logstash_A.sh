#!/usr/bin/env bash

docker-machine create -d virtualbox --virtualbox-memory 2048 worker$1
docker-machine ssh worker$1 'sudo sh -c "echo "vm.max_map_count=262144" >> /etc/sysctl.conf"'
docker-machine ssh worker$1 'sudo sysctl -w vm.max_map_count=262144 '

WORKER_TOKEN=`docker-machine ssh manager "docker swarm join-token worker -q"`
MANAGER_IP="192.168.99.100"

docker-machine ssh worker$1 "docker swarm join --token $WORKER_TOKEN $MANAGER_IP"
docker-machine ssh manager "docker node update worker$1"
docker-machine ssh manager "docker service scale elastic_logstashA=$2 --detach"
