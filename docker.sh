#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/docker_script/log.sh

FUNCTION=""
function lower() {
  echo $1 | tr '[A-Z]' '[a-z]'
}

function upper() {
  echo $1 | tr '[a-z]' '[A-Z]'
}

function print_help() {
  cat <<EOF
Sensor calibration tool execution script
Usage: $0  <function>
OPTIONS:
  ./docker.sh.sh
  build                   build docke file[./docker.sh build]
  exec                    Entering Docker Container[./docker.sh exec]
EOF
}

function error() {
  echo "$1" >&2
}


function is_yq_install(){
  
  if [ -e "$SCRIPT_DIR/tools/yq" ]; then
    log_info "yq File exists"
  else
    log_info "Start downloading yq"
    YQ_VERSION="v4.16.2"
    YQ_BINARY="yq_linux_amd64"
    wget -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O $SCRIPT_DIR/tools/yq
  fi


  if ! which yq > /dev/null; then
    read -p "yq command not found. Do you want to install it? (Y/n) " choice
    case "$choice" in
      y|Y )
        # 自动安装 yq 命令
        chmod +x $SCRIPT_DIR/yq

        sudo cp $SCRIPT_DIR/tools/yq /usr/bin/yq
        ;;
      * )
        log_warning "Please install yq command manually."
        exit 1
        ;;
    esac
  fi

}

function parse_arguments(){
  
  while [ $# -gt 0 ]; do
    local opt="$1"
    shift
    case "${opt}" in
      -h | --help)
        print_help
        exit 0
        ;;
      build)
        log_info "docker build"
        $SCRIPT_DIR/docker_script/docker_build.sh
        exit 0
        ;;
      exec)
        log_info "docker exec"
        $SCRIPT_DIR/docker_script/docker_exec.sh
        exit 0
        ;;
      --)  # end argument parsing
        shift
        break
        ;;

      -*|--*=)  # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;

      *)  # unsupported positional arguments
        echo "Error: Unsupported positional argument $1" >&2
        print_help
        exit 1
        ;;
    esac
  done # End while loop
  


}

function main(){
  is_yq_install

  parse_arguments $@

}
main $@