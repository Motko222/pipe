#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Sure? " c
case $c in y|Y) ;; *) exit ;; esac

systemctl stop $folder.service
systemctl disable $folder.service
rm /etc/systemd/system/$folder.service

mkdir /root/backup/$folder" folder"
cp /root/$folder/node_info.json /root/backup/$folder" folder"
rm -r /root/$folder
mv /root/scripts/$folder /root/backup
rm -r /root/backup/$folder/.git
bash /root/scripts/system/influx-delete-id.sh $folder

