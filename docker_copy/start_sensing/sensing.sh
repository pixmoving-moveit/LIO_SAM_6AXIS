#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/log.sh

source /root/workspace/lidar_mapping/devel/setup.zsh
roslaunch $SCRIPT_DIR/sensing.launch
