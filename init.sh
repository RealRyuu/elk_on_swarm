#!/usr/bin/env bash

MANAGER_IP="192.168.99.100"
N_WORKERS=3

MANAGER_MEM=1024
WORKER_MEM=2048

MANAGER_NAME="manager"
WORKER_NAME="worker"

NETWORK_NAME="elastic"

docker-machine create -d virtualbox --virtualbox-memory $MANAGER_MEM $MANAGER_NAME

for index in $(seq 1 $N_WORKERS);
do
   docker-machine create -d virtualbox --virtualbox-memory $WORKER_MEM worker$index
done

docker-machine ssh $MANAGER_NAME "docker swarm init --advertise-addr $MANAGER_IP"

MANAGER_TOKEN=`docker-machine ssh $MANAGER_NAME "docker swarm join-token manager -q"`
WORKER_TOKEN=`docker-machine ssh $MANAGER_NAME "docker swarm join-token worker -q"`

docker-machine ssh $MANAGER_NAME 'sudo sh -c "echo "vm.max_map_count=262144" >> /etc/sysctl.conf"'
docker-machine ssh $WORKER_NAME$index 'sudo sysctl -w vm.max_map_count=262144 '

for index in $(seq 1 $N_WORKERS);
do
   docker-machine ssh $WORKER_NAME$index 'sudo sh -c "echo "vm.max_map_count=262144" >> /etc/sysctl.conf"'
   docker-machine ssh $WORKER_NAME$index 'sudo sysctl -w vm.max_map_count=262144 '
   docker-machine ssh $WORKER_NAME$index "docker swarm join --token $WORKER_TOKEN $MANAGER_IP"
done

docker-machine ssh $MANAGER_NAME "docker network create --driver overlay --attachable $NETWORK_NAME"
docker-machine ssh $MANAGER_NAME "docker node update --label-add region=elasticsearch worker1"
