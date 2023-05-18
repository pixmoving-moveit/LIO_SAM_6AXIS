#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/log.sh

docker stop lidar_mapping1
sleep 1
docker rm  lidar_mapping1
sleep 1
docker rmi  lidar_mapping1