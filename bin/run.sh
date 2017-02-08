#!/bin/bash
sleep 10
/prepare-env.sh && echo "Preparation successfully finished"
exec "$@"
