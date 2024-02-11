#!/bin/bash

LOG_FILE="/usr/local/hestia/log/system.log"

tail -n0 -f "$LOG_FILE" | grep --line-buffered -E "v-(delete|add|change)-dns-record" | while read -r line
do
    echo "$line"
    echo "Відповідна дія, яку потрібно виконати"
done
