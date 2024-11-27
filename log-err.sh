#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

journalctl -u $folder.service --no-hostname -o cat | grep -E "ERR|rror"
