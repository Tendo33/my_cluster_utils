if [ ! -d "./nccl-tests" ]; then
    git clone https://github.com/NVIDIA/nccl-tests.git
    cd nccl-tests/
    # ngc 容器里通过whereis mpirun 查看
    make MPI=1 MPI_HOME=/opt/hpcx/ompi/
fi