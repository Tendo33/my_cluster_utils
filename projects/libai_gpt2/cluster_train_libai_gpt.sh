set -ex
# 解析输入参数，使用逗号分割多个主机名
hosts=$(echo $1 | tr "," "\n")
master_addr=$2
# 获取主机数量
ACC=$3
num_hosts=$(echo $hosts | wc -w)

# 使用ansible在每个主机上执行命令
for (( i=0; i<$num_hosts; i++ )); do
  host=$(echo $hosts | cut -d " " -f $((i+1)))

  ansible $host -m shell -a "docker exec gpt_libai bash -c 'cd /data_32T/home/sunjinfeng/workspace/libai && bash tools/args_train.sh configs/gpt2_pretrain.py $num_hosts 8 $i $master_addr 1 1 true true ture 2 $ACC false 2 220 100 48 144 2304 9216'" & 

done
