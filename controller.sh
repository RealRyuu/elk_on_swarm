N_WORKERS=3
MANAGER_IP="192.168.99.100"

MANAGER_TOKEN=`docker-machine ssh manager "docker swarm join-token manager -q"`
WORKER_TOKEN=`docker-machine ssh manager "docker swarm join-token worker -q"`

while true; do

for index in $(seq 1 $N_WORKERS);
do

USED=$(docker-machine ssh worker$index "free -t -m | tail -n 1 | tr -s ' ' | cut -d ' ' -f 3")
TOTAL=$(docker-machine ssh worker$index "free -t -m | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2")

USAGE=$(echo "scale=2; $USED / $TOTAL" | bc)
echo "mem usage worker$index: $USAGE\n"
if [ $(echo "scale=2; $USAGE >= 0.5" | bc) -eq 1 ]
then
  echo "scaling up\n"
  #docker-machine create -d virtualbox --virtualbox-memory 2048 worker$N_WORKERS
  #docker-machine ssh worker$N_WORKERS "docker swarm join --token $WORKER_TOKEN $MANAGER_IP"
  #N_WORKERS=$((N_WORKERS+1))
  echo "mem usage worker$index: $USAGE\n"
fi

done

done

