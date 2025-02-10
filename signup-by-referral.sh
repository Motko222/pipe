#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Referral code?" ref

cd /root/$folder
./pop --signup-by-referral-route $ref
