#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

systemctl restart $folder.service
sleep 5s
journalctl -n 100 -f $folder.service --no-pager
