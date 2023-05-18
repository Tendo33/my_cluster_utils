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

    ansible $host -m shell -a "docker exec gpt_libai bash -c 'cd /data_turbo/home/sunjinfeng/workspace/Megatron && bash examples/megatron_args_pretrain_gpt2.sh $num_hosts 8 $i $master_addr 1 1 true true true 2 $ACC false 2 220 100 48 144 2304 9216'" & 

done
