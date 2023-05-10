#!/bin/bash
set -ex
# 解析输入参数，使用逗号分割多个主机名
hosts=$(echo $1 | tr "," "\n")
master_addr=$2
# 获取主机数量
num_hosts=$(echo $hosts | wc -w)

global_batch_size=$(($num_hosts * 16))
# 使用ansible在每个主机上执行命令
for (( i=0; i<$num_hosts; i++ )); do
  host=$(echo $hosts | cut -d " " -f $((i+1)))

  #ansible $host -m shell -a "docker exec gpt_libai bash -c 'cd /data_32T/home/xuxiaoyu/workspace && bash train_libai_gpt.sh'" -i ~/inventory.ini &

  #32n
  ansible $host -m shell -a "docker exec gpt_libai bash -c 'cd /data_32T/home/xuxiaoyu/workspace && bash train_libai_gpt.sh 0 $num_hosts 8 $i $master_addr 1 1 true true false $3 $4'" -i ~/inventory.ini &

  # 56n
  #ansible $host -m shell -a "docker exec gpt_libai bash -c 'cd /data_32T/home/xuxiaoyu/workspace && bash train_libai_gpt.sh 0 $num_hosts 8 $i $master_addr 1 1 true true false $3 $4'" -i ~/inventory.ini &

done
