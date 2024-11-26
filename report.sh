#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

version=$(echo ?)
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(journalctl -u $folder.service --no-hostname -o cat | grep $(date --utc +%F) | grep -c -E "rror|ERR")
address=$(journalctl -u $folder.service --no-hostname -o cat | grep "Waiting For Your Node" | tail -1 | awk -F "Waiting For Your Node\(" '{print $NF}' | cut -d \) -f 1 )
url=$(cat /root/$folder/config.yaml | grep Listen | cut -d \" -f 2)


status="ok"
[ $service -ne 1 ] && status="error";message="service not running";
[ $errors -gt 0 ] && status="warning";message="errors=$errors";

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$folder",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"opBNB testnet",
        "network":"testnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":$service,
        "errors":$errors,
        "address":"$address",
        "url":"$url"
  }
}
EOF

cat $json | jq
