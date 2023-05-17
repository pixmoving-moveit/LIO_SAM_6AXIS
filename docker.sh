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
  echo "Sensor calibration tool execution script"
  echo ""
  echo "Usage:"
  echo "  ./docker.sh.sh <function>"
  echo ""
  echo "  <function>: function name"
  echo "  <function>: build exec "
  echo "    - build build docke file[./docker.sh build]"
  echo "    - exec Entering Docker Container[./docker.sh exec]"
  echo ""
}

function error() {
  echo "$1" >&2
}


function is_yq_install(){
  
  if [ -e "$SCRIPT_DIR/docker_script/yq" ]; then
    log_info "yq File exists"
  else
    log_info "Start downloading yq"
    YQ_VERSION="v4.16.2"
    YQ_BINARY="yq_linux_amd64"
    wget -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O $SCRIPT_DIR/docker_script/yq
  fi


  if ! which yq > /dev/null; then
    read -p "yq command not found. Do you want to install it? (Y/n) " choice
    case "$choice" in
      y|Y )
        # 自动安装 yq 命令
        chmod +x $SCRIPT_DIR/docker_script/yq

        sudo cp $SCRIPT_DIR/docker_script/yq /usr/bin/yq
        ;;
      * )
        log_warning "Please install yq command manually."
        exit 1
        ;;
    esac
  fi

}

function parse_arguments() {
  FUNCTION=$1
  shift 1
  if [[ -z $FUNCTION ]]; then
    log_error "Missing required argument(s)."
    echo ""
    print_help
    exit 1
  fi
  
  case "$FUNCTION" in
    build)
    log_info "docker build"
    $SCRIPT_DIR/docker_script/docker_build.sh
    ;;

    exec)
    log_info "docker exec"
    $SCRIPT_DIR/docker_script/docker_exec.sh
    ;;
  esac

  while (( "$#" )); do
    case "$1" in

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
        exit 1
        ;;
    esac
  done
}

function main(){
  if [[ "help" == `lower $1` ]]; then
    print_help
    exit 0
  fi

  is_yq_install

  parse_arguments $@

}
main $@