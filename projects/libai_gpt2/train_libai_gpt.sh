set -ex

#export NCCL_SOCKET_IFNAME=eth0
export NCCL_IB_DISABLE=0
export NCCL_DEBUG=INFO
export NCCL_IB_GID_INDEX=3
export NCCL_GDR_LEVEL=2
export NCCL_TOPO_FILE=/data_32T/home/workspace/nccl-tests/nccl_topo_a800_1.6t.xml
export NCCL_IB_QPS_PER_CONNECTION=4
#export NCCL_IB_TC=160
#export NCCL_IB_HCA=mlx5_bond_0:1,mlx5_bond_1:1,mlx5_bond_2:1,mlx5_bond_3:1,mlx5_bond_4:1,mlx5_bond_5:1,mlx5_bond_6:1,mlx5_bond_7:1

export ONEFLOW_COMM_NET_IB_GID_INDEX=3
#export ONEFLOW_COMM_NET_IB_HCA=$NCCL_IB_HCA
export ONEFLOW_COMM_NET_IB_HCA=mlx5_bond_1:1

# Dangerous, May casue long time to fail
#export ONEFLOW_RPC_BOOTSTRAP_SERVER_MAX_RETRY_TIMES=60
#export ONEFLOW_RPC_CLIENT_MAX_RETRY_TIMES=60

python3 -m oneflow --doctor

LIBAI_PWD=/data_32T/home/xuxiaoyu/workspace


CONFIG=$1
NNODES=${2:-1}
GPUS_PER_NODE=${3:-8}
NODE_RANK=${4:-0}
MASTER_ADDR=${5:-"127.0.0.1"}
MASTER_PORT=12345
MP=${6:-1}
PP=${7:-1}
GRAPH_ENABLED=${8:-true}
USE_FP16=${9:-true}
ACTIVATION_CHECKPOINT=${10:-false}
MICRO_BATCH_SIZE=${11:-4}
GLOBAL_BATCH_SIZE=${12:-4}
#ZERO_ENABLE=${13:-false}
#ZERO_STAGE=${14:-2}
#TRAIN_ITERS=${15:-220}
#LOG_PERIOD=${16:-100}
#NUM_LAYER=${17:-12}
#NUM_ATT_HEADS=${18:-12}
#HIDDEN_SIZE=${19:-768}
#INTERMEDIATE_SIZE=${20:-3072}
#HEAD_SIZE=${21:-64}
#SAVE_MODEL=${22:-false}
#UNSET_DROPOUT=${23:-false}

#ONEFLOW_BRANCH_NAME=${1:-"master"}
#LIBAI_BRANCH_NAME=${2:-"main"}
#INSTALL=${3:-false}
ONEFLOW_BRANCH_NAME="master"
LIBAI_BRANCH_NAME="main"
INSTALL=false

if $INSTALL; then
  python3 -m pip uninstall -y oneflow
  if [ $ONEFLOW_BRANCH_NAME == 'master' ]; then
    python3 -m pip install --pre oneflow -f https://staging.oneflow.info/branch/${ONEFLOW_BRANCH_NAME}/cu117
  else
    python3 -m pip install --pre oneflow -f https://staging.oneflow.info/canary/refs/heads/${ONEFLOW_BRANCH_NAME}/cu117/index.html
  fi
fi


if [ ! -d "${LIBAI_PWD}/libai" ]; then
  echo "==> clone libai"
  git clone -b $LIBAI_BRANCH_NAME --depth 1 https://github.com/Oneflow-Inc/libai.git
else
  echo "==> skip clone libai"
fi


if [ ! -d "${LIBAI_PWD}/libai/data_test/gpt_data" ]; then
  echo "==> downloading gpt data"
  mkdir -p ${LIBAI_PWD}/libai/data_test/gpt_data
  wget -nc https://oneflow-test.oss-cn-beijing.aliyuncs.com/OneFlowAutoTest/libai/dataset/gpt2-vocab.json  -P ${LIBAI_PWD}/libai/data_test/gpt_data
  wget -nc https://oneflow-test.oss-cn-beijing.aliyuncs.com/OneFlowAutoTest/libai/dataset/gpt2-merges.txt  -P ${LIBAI_PWD}/libai/data_test/gpt_data
  wget -nc https://oneflow-test.oss-cn-beijing.aliyuncs.com/OneFlowAutoTest/libai/dataset/loss_compara_content_sentence.bin  -P ${LIBAI_PWD}/libai/data_test/gpt_data
  wget -nc https://oneflow-test.oss-cn-beijing.aliyuncs.com/OneFlowAutoTest/libai/dataset/loss_compara_content_sentence.idx  -P ${LIBAI_PWD}/libai/data_test/gpt_data
else
  echo "==> skip downloading gpt data"
fi

#rm ./libai/tools/args_train.sh
#wget -nc  https://raw.githubusercontent.com/Oneflow-Inc/OneAutoTest/megatron_script_tecent/onebench/libai/args_train.sh -P ./libai/tools/
if [ ! -s "${LIBAI_PWD}/libai/tools/args_train.sh" ]; then
  echo "==> get train sh"
  wget -nc https://raw.githubusercontent.com/strint/OneAutoTest/patch-1/onebench/libai/args_train.sh -P ${LIBAI_PWD}/libai/tools/
else
  echo "==> skip get train sh"
fi


cd libai
if [ $LIBAI_BRANCH_NAME != 'main' ]; then
    git remote set-branches origin $LIBAI_BRANCH_NAME
    git fetch --depth 1 origin $LIBAI_BRANCH_NAME
    git checkout $LIBAI_BRANCH_NAME
fi

#python3 -m pip uninstall -y libai
LIBAI_INSTALLED=1
python3 -m pip list | grep libai || LIBAI_INSTALLED=0
if [ ${LIBAI_INSTALLED} == 0 ]; then
  echo "==> libai not installed, installing..."
  python3 -m pip install -r requirements.txt
  python3 -m pip install -e . --user
else
  echo "==> skip installing libai"
fi


## GPT-2
# 3090 

#  1n1g         gpt2_nl24_nah16_hs1024_fp16_actrue_mp1_pp1_mb8_gb8_1n1g
#bash tools/args_train.sh configs/gpt2_pretrain.py 1 1 0 127.0.0.1 1 1 true true true 8 8 false 0 220 100 24 16 1024 4096


#export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
#  1n8g 模型并行        gpt2_nl24_nah16_hs1024_fp16_acfalse_mp8_pp1_mb2_gb2_1n8g
#bash tools/args_train.sh configs/gpt2_pretrain.py 1 8 0 127.0.0.1 8 1 true true false 2 2 false 0 220 100 24 16 1024 4096

# general train

# 32n
bash tools/args_train.sh configs/gpt2_pretrain.py $NNODES $GPUS_PER_NODE $NODE_RANK $MASTER_ADDR $MP $PP $GRAPH_ENABLED $USE_FP16 $ACTIVATION_CHECKPOINT $MICRO_BATCH_SIZE $GLOBAL_BATCH_SIZE false 0 2200 100 24 16 1024 4096

# 56n
#bash tools/args_train.sh configs/gpt2_pretrain.py $NNODES $GPUS_PER_NODE $NODE_RANK $MASTER_ADDR $MP $PP $GRAPH_ENABLED $USE_FP16 $ACTIVATION_CHECKPOINT $MICRO_BATCH_SIZE $GLOBAL_BATCH_SIZE false 0 220000 1000 48 16 1024 4096


#python3 -m pip uninstall -y libai
