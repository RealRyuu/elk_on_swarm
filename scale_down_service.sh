#!/usr/bin/env bash

node_to_purge=`docker-machine ssh manager "docker node ls" | tail -n 1 | tr -s ' ' | cut -d " " -f2`
docker-machine ssh manager "docker node update --availability drain $node_to_purge"
docker-machine ssh manager "docker service scale $1$2"
docker-machine ssh manager "docker node rm $node_to_purge --force"
docker-machine rm $node_to_purge -y
docker-machine ssh manager "docker service update $1"
