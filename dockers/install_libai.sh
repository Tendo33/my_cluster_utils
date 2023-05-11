set -ex

LIBAI_PWD=/data_32T/home/sunjinfeng/workspace

cd libai

#python3 -m pip uninstall -y libai
LIBAI_INSTALLED=1
python3 -m pip list | grep libai || LIBAI_INSTALLED=0
if [ ${LIBAI_INSTALLED} == 0 ]; then
  echo "==> libai not installed, installing..."
  python3 -m pip install -r requirements.txt
  python3 -m pip install -e .
else
  echo "==> skip installing libai"
fi