#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/log.sh

# shell function to check if a rostopic has output
function check_ros_topic {
    local topic_name=$1
    local timeout_time=${2:-2s}

    start=$(date +%s.%N) 
    timeout $timeout_time rostopic echo  ${topic_name} -n 1  > /dev/null 2>&1
    
    if [ ! $? -eq 0 ]; then
        end=$(date +%s.%N)
        runtime=$(echo "$end - $start" | bc)
        
        if (( $(echo "$runtime > 1" | bc -l) )); then  
            log_error "$topic_name -- NoData"
        else
            log_error "$topic_name -- non-existent[$runtime]"
        fi
        
        return 1
    fi

    local output=""
    output=$(rostopic echo ${topic_name} -n 1 2>/dev/null)

    if [[ ! -z "${output}" ]]; then
        log_info "$topic_name -- state normal"
        return 0
    fi
}

function read_topic_names(){
    topic_names=$(yq e '.topic_names | .[]' $1)
    # output:/sensing/gnss/pose /sensing/lidar/top/rslidar_sdk/rs/points
    conut=0

    for ITEM in $topic_names; do
        check_ros_topic $ITEM
        conut=$(expr $conut + $?)
    done
    
    if [[ $conut>0 ]];then
        log_error "Record the success or failure of the topic"
        exit 1
    fi
}

function collect_rosbag(){
    bag_prefix_name=$(yq e '.bag_prefix_name' $config_name)
    bag_dir_path=$(yq e '.bag_dir_path' $config_name)
    rosbag_path=$bag_dir_path"/"$bag_prefix_name"_"$(date +"%Y-%m-%d-%H_%M_%S")

    if [ ! -d "$rosbag_path" ]; then
        mkdir -p "$rosbag_path"
    fi

    cd $rosbag_path
    latest_bag=$bag_dir_path"/"$bag_prefix_name"latest_bag"
    ln -sf $rosbag_path $latest_bag

    log_info "Start collect:[$rosbag_path]"
    rosbag record --split --size=2048 --buffsize=1024  $topic_names
    log_info "collect Success:[$rosbag_path]"
    log_info "-------------------------------------------------------"
    rosbag info $latest_bag/*.bag
    log_info "-------------------------------------------------------"
}

function main(){
    topic_names=""
    config_name=$1

    if [ -z "$config_name" ];then
        log_error "请输入[ ./collect_rosbag.sh imu.yaml]"
        exit 1
    fi
    
    read_topic_names $config_name
    collect_rosbag
    
}
main $1