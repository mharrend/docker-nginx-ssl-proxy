#!/bin/sh
sleep 10
echo "Install bash and tools necessary later"
apk add bash bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils grep
/prepare-env.sh && echo "Preparation finished"
echo " finished preparation"
#exec nginx -g "daemon off;"
