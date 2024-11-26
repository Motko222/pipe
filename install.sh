#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Port? " port
read -p "Pk? " pk

#download binary
[ -d /root/$folder] || mkdir /root/$folder
cd /root/$folder
wget https://github.com/Glacier-Labs/node-bootstrap/releases/download/v0.0.2-beta/verifier_linux_amd64
chmod +x ./verifier_linux_amd64

#create config.yaml
sudo tee /root/$folder/config.yaml > /dev/null <<EOF
Http:
  Listen: "127.0.0.1:$port"
Network: "testnet"
RemoteBootstrap: "https://glacier-labs.github.io/node-bootstrap/"
Keystore:
  PrivateKey: "$pk"
TEE:
  IpfsURL: "https://greenfield.onebitdev.com/ipfs/"
EOF

sudo tee /etc/systemd/system/$folder.service > /dev/null <<EOF
[Unit]
Description=$folder
After=network.target
[Service]
User=root
ExecStart=/root/$folder/verifier_linux_amd64
Restart=always
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $folder
