#!/bin/bash

/usr/bin/tail -r /Library/Addigy/logs/cache.log | /usr/bin/grep -E -m1 "Peers: [[:digit:]]$" | /usr/bin/awk 'END {print $NF}'
