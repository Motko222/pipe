#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

#download binary
[ -d /root/$folder] || mkdir /root/$folder
cd /root/$folder
curl -L -o pop "https://dl.pipecdn.app/v0.2.4/pop"
chmod +x pop
mkdir download_cache

#create service
sudo tee /etc/systemd/system/$folder.service << 'EOF'
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=root
Group=root
ExecStart=/root/$folder/pop \
    --ram=$RAM \
    --pubKey $WALLET \
    --max-disk $DISK \
    --cache-dir /root/$folder/download_cache \
    --no-prompt
Restart=always
RestartSec=30
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$folder
WorkingDirectory=/root/$folder

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $folder
