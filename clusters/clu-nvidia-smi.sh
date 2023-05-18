
# 检查环境
ansible all -m shell -a "nvidia-smi" 
ansible test -m shell -a "docker ps -a" 

ansible test -m shell -a "ps -ef | grep python" 
ansible test -m shell -a "docker exec gpt_libai_sjf bash -c 'pip list | grep libai'"

ansible test -m shell -a "docker exec gpt_libai_sjf bash -c 'python3 -m oneflow --doctor'"

# 安装 nccl-rdma-sharp-plugins-1.0-1.x86_64.rpm 插件

ansible test -m shell -a "docker exec gpt_libai_sjf bash -c 'apt-get -y install rpm'"

ansible test -m shell -a "docker exec gpt_libai_sjf bash -c 'rpm -e nccl-rdma-sharp-plugins-1.0-1.x86_64'"

ansible test -m shell -a "docker exec gpt_libai_sjf bash -c 'cd /data_turbo/home/sunjinfeng/workspace && rpm -ivh --nodeps --force nccl-rdma-sharp-plugins-1.0-1.x86_64.rpm'"

# 安装 5.3 版本的插件
ansible test -m shell -a "docker exec test_libai_sjf bash -c 'rm -rf /opt/hpcx/nccl_rdma_sharp_plugin && ldconfig'"
ansible test -m shell -a "docker exec test_libai_sjf bash -c 'cd /data_turbo/home/sunjinfeng/workspace && dpkg -i nccl-rdma-sharp-plugins_1.1_amd64.deb'"


# 安装htop 和 python3-pip
ansible test -m shell -a "docker exec NCCL_test_sjf bash -c 'apt-get -y install htop'"
ansible test -m shell -a "docker exec NCCL_test_sjf bash -c 'apt-get -y install python3-pip'"

# 安装libai
ansible install_libai -m shell -a "docker exec NCCL_test_sjf bash -c 'cd /data_turbo/home/sunjinfeng/workspace/libai && python3 -m pip install -r requirements.txt'"
ansible install_libai -m shell -a "docker exec NCCL_test_sjf bash -c 'cd /data_turbo/home/sunjinfeng/workspace/libai && python3 -m pip install -e .'"

# 分发镜像
ansible test -m shell -a "docker load -i /data_32T/docker_images/ngc_ssh_ib54_config_21.07_py3.tar"
ansible install_libai -m shell -a "docker load -i /data_turbo/docker_images/ngc_ssh_21.07_py39.tar"

# 停止并删除容器
ansible test -m shell -a "docker stop gpt_test_sjf"

ansible test -m shell -a "docker rm gpt_test_sjf"

# 安装 libai
ansible install_libai -m shell -a "docker exec gpt_libai_sjf bash -c 'pip list | grep libai'"

ansible test -m shell -a "docker ps -a| grep sjf"


python3 -m pip uninstall -y libai
python3 -m pip install -r requirements.txt
python3 -m pip install -e .

ansible test -m shell -a "docker exec test_libai_sjf bash -c  'sed -i 's/Port 62620/Port 10097/g' /root/.ssh/config && /usr/sbin/sshd -p 10097'"
ansible test -m shell -a "docker exec gpt_test_sjf bash -c 'cp -f /data_turbo/home/sunjinfeng/workspace/config /root/.ssh/'"

ansible test -m shell -a "docker exec gpt_test_sjf bash -c 'chmod 644 ~/.ssh/config'"