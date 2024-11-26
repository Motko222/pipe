#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

version=$(echo ?)
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(cat ~/aethir/log/server.log | grep $(date --utc +%F) | grep -c -E "rror|ERR")

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
        "chain":"arbitrum one",
        "network":"mainnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":$service,
        "errors":$errors
  }
}
EOF

cat $json | jq
