#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

url=https://dl.pipecdn.app/v0.2.8/pop

#download binary
[ -d /root/$folder ] || mkdir /root/$folder
cd /root/$folder
[ -f pop ] && rm pop
curl -s -L -o pop $url
chmod +x pop
[ -d download_cache ] || mkdir download_cache

#create service
printf "[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
User=root
Group=root
ExecStart=/root/$folder/pop --ram=$RAM --pubKey $WALLET --max-disk $DISK --cache-dir /root/$folder/download_cache --no-prompt --enable-80-443
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
