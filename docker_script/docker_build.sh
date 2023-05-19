#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source $SCRIPT_DIR/log.sh
config_file_path=$SCRIPT_DIR/config.yaml

docker_image_name=$(yq e      '.docker_config.docker_image_name'     $config_file_path )
docker_image_version=$(yq e   '.docker_config.docker_image_version'  $config_file_path )


function dockerfile_build(){
  log_info "create $docker_image_name docker image ... "
  # docker build --build-arg dockerfile_path=$SCRIPT_DIR/../ -t $docker_image_name $SCRIPT_DIR/..
  sudo docker build --build-arg dockerfile_path=$SCRIPT_DIR/../  -t $docker_image_name:$docker_image_version  "$SCRIPT_DIR/../"
}


function is_rm_image(){
  read -p "Do you want to remove [$docker_image_name] image? (Y/n) " choice

  case "$choice" in
    y|Y )
      log_info "Removing mirror [$docker_image_name]"
      docker rmi $docker_image_name:$docker_image_version
      ;;
    n|N )
      exit 1
      ;;
    * )
      log_error "Invalid input. Please enter Y or N."
      exit 1
      ;;
  esac
}


function tar_compress_folder(){
  log_info "dockerfile COPY file"
  tar_file_path=$SCRIPT_DIR/../docker_copy.tar.gz
  if [ ! -f "$tar_file_path" ]; then
    cp $SCRIPT_DIR/yq $SCRIPT_DIR/../docker_copy/
    tar -czvf  $tar_file_path   $SCRIPT_DIR/../docker_copy/
  fi
}

function main(){
  if docker images | grep -q $docker_image_name; then
    log_warning "docker image exists:[$docker_image_name]"
    is_rm_image
  fi
  tar_compress_folder
  dockerfile_build
}

main