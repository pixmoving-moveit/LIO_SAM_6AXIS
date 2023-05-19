#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/log.sh


if [ -e "/usr/bin/yq" ]; then
    log_info "yq File exists"
else
  log_info "Start install yq"
  mv /root/workspace/tools/yq /usr/bin/yq && chmod +x /usr/bin/yq
fi

cd /root/workspace/lidar_mapping
source /opt/ros/melodic/setup.bash
catkin_make 