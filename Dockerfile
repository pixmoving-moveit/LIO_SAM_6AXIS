# check more detail on: https://hub.docker.com/r/nvidia/cuda
# image name: lidar_mapping
FROM nvidia/cuda:11.3.1-devel-ubuntu18.04
LABEL maintainer="Mark Jin <mark@pixmoving.net>"

# Just in case we need it
ENV DEBIAN_FRONTEND noninteractive

# basic elements
RUN sed -i s@/archive.ubuntu.com/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list \
    && apt-get clean \
    && apt update \
    && apt install -y --no-install-recommends git curl vim rsync ssh wget zsh tmux g++

# ==========> INSTALL zsh <=============
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p https://github.com/agkozak/zsh-z \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# ==========> INSTALL ROS melodic <=============
RUN apt update && apt install -y curl lsb-release
# for Chinese developer
RUN sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-la
test.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update && apt install -y ros-melodic-desktop-full
RUN apt-get install -y libgtest-dev ros-melodic-catkin python-pip python3-pip

RUN echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# needs to be done before we can apply the patches

# ===========> Install Packages <==============
# Install C++ Dependencies
# RUN apt-get update && apt-get install --no-install-recommends -y \
RUN apt-get install --no-install-recommends -y \
    libgeographic-dev \
    libblosc-dev \
    libboost-iostreams-dev \
    libboost-numpy-dev \
    libboost-python-dev \
    libboost-system-dev \
    libeigen3-dev \
    libtbb-dev \
    libgflags-dev \
    libgl1-mesa-glx \
    libgoogle-glog-dev \
    protobuf-compiler \
    python3-catkin-tools \
    python3-pip \
    python3-colcon-common-extensions \
    python3-setuptools python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# ======================> DEPENDENCIES <=========================
# gtsam 4.0.2 --> https://github.com/borglab/gtsam/issues/145
RUN git clone git clone https://github.com/borglab/gtsam.git \
    && cd gtsam && git checkout b10963802c13893611d5a88894879bed47adf9e0 \
    && mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# resolved the conflict ========> see issue: https://github.com/ethz-asl/lidar_align/issues/16#issuecomment-504348488
RUN mv /usr/include/flann/ext/lz4.h /usr/include/flann/ext/lz4.h.bak  && \
    mv /usr/include/flann/ext/lz4hc.h /usr/include/flann/ext/lz4.h.bak && \
    ln -s /usr/include/lz4.h /usr/include/flann/ext/lz4.h && \
    ln -s /usr/include/lz4hc.h /usr/include/flann/ext/lz4hc.h

RUN mkdir -p /root/workspace/src && mkdir -p /home/lidar_mapping/data
WORKDIR /root/workspace
RUN cd src && git clone https://github.com/pixmoving-moveit/LIO_SAM_6AXIS.git