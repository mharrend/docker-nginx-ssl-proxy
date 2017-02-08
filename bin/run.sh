#!/bin/bash
sleep 10
/prepare-env.sh && echo "Preparation finished"
echo " finished preparation"
exec "$@"
