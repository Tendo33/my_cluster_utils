#!/bin/bash

SSHD_PORT=$1
IMAGE_NAME=${2:-"ngc/pytorch-21.07:ssh-ib5.3-config-py38"}
MOUNT_PATH=${3:-"/data_turbo/home/sunjinfeng/workspace"}
CONTAINER_NAME=${4:-"gpt_libai_sjf"}

docker run --gpus all -itd --shm-size=16g --ulimit memlock=-1  --ulimit core=0 --ulimit stack=67108864 --privileged --cap-add=IPC_LOCK --name $CONTAINER_NAME --ipc host --net host -v ${MOUNT_PATH}:${MOUNT_PATH} $IMAGE_NAME bash -c "sed -i 's/Port 62620/Port ${SSHD_PORT}/g' /root/.ssh/config && /usr/sbin/sshd -p ${SSHD_PORT} && bash"

docker run --gpus all -itd --shm-size=16g --ulimit memlock=-1  --ulimit core=0 --ulimit stack=67108864 --privileged --cap-add=IPC_LOCK --name "gpt_test_sjf" --ipc host --net host -v "/data_turbo/sunjinfeng/workspace":"/data/sunjinfeng/workspace" "ngc-ssh/pytorch:21.07-py3" bash -c "sed -i 's/Port 62620/Port 11097/g' /root/.ssh/config && /usr/sbin/sshd -p 11097 && bash"

docker attach gpt_test_sjf