#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

#download binary
[ -d /root/$folder ] || mkdir /root/$folder
cd /root/$folder
curl -s -L -o pop $URL
chmod +x pop
[ -d download_cache ] || mkdir download_cache

#create service
printf "[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=root
Group=root
ExecStart=/root/$folder/pop --ram=$RAM --pubKey $WALLET --max-disk $DISK --cache-dir /root/$folder/download_cache --no-prompt
Restart=always
RestartSec=30
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$folder
WorkingDirectory=/root/$folder

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$folder.service

sudo systemctl daemon-reload
sudo systemctl enable $folder
