ansible else -m shell -a "bash /data_turbo/home/sunjinfeng/workspace/my_cluster_utils/dockers/run_dockers.sh 19033" 


ansible install_libai -m shell -a "docker run --gpus all -itd --shm-size=16g --ulimit memlock=-1  --ulimit core=0 --ulimit stack=67108864 --privileged --cap-add=IPC_LOCK --name "NCCL_test_sjf" --ipc host --net host -v "/data_turbo/home/sunjinfeng/workspace":"/data_turbo/home/sunjinfeng/workspace" "ngc/pytorch-21.07:ssh-ib5.4-config-py38" bash -c "sed -i 's/Port 62620/Port 19035/g' /root/.ssh/config && /usr/sbin/sshd -p 19035 && bash" "