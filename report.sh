#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
status=/root/logs/$folder-status
source ~/.bash_profile
source $path/config

cd /root/$folder
./pop --status > $status

uptime=$(cat $status | grep "Uptime Score:" | awk '{print $NF}')
egress=$(cat $status | grep "Egress Score:" | awk '{print $NF}')
historical=$(cat $status | grep "Historical Score:" | awk '{print $NF}')
score=$(cat $status | grep "TOTAL SCORE:" | awk '{print $3}')
node=$(cat $status | grep "Reputation Status for Node:" | awk '{print $NF}')
version=$(journalctl -u $folder.service --no-hostname -o cat | grep "You are on version" | tail -1 | awk '{print $NF}')
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(journalctl -u $folder.service --no-hostname -o cat | grep $(date --utc +%F) | grep -c -E "rror|ERR")
address=$(journalctl -u $folder.service --no-hostname -o cat | grep "Waiting For Your Node" | tail -1 | awk -F "Waiting For Your Node\(" '{print $NF}' | cut -d \) -f 1 )


status="ok" && message="score=$score"
[ $service -ne 1 ] && status="error" && message="service not running";
[ $errors -gt 20 ] && status="warning" && message="errors=$errors";

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
        "chain":"?",
        "network":"testnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":$service,
        "errors":$errors,
        "wallet":"$WALLET",
        "ram":"$RAM",
        "disk":"$DISK",
        "uptime":"$uptime",
        "egress":"$egress",
        "historical":"$historical",
        "score":"$score",
        "node":"$node"
  }
}
EOF

cat $json | jq
