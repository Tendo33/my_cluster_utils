ansible nvidia-smi -m shell -a "nvidia-smi" -i ~/inventory.ini


ansible nvidia-smi -m shell -a "ps -ef | grep python" -i ~/inventory.ini
