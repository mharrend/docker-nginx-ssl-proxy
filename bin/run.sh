#!/bin/bash
sleep 30
echo $PWD
ls $PWD
ls /
/prepare-env.sh && echo "Start preparation finished"
echo " finished preparation"
#exec nginx -g "daemon off;"
