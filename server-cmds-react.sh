#!/usr/bin/env bash 
export IMAGE=$1
export IMAGE_TAG=$2
docker compose -f docker-compose-react.yml up --detach
docker images --format "{{.ID}} {{.Repository}}:{{.Tag}}" | awk '$2=="your-image-name"{print $1, $2":"$3}' | sort -k 2 -r | awk 'NR>1{print $1}' | (read id; [ -z "$id" ] || { echo "$id"; xargs docker rmi; })
