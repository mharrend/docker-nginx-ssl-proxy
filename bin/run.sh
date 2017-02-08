sleep 30
./prepare-env.sh && echo "Start preparation finished"
exec nginx -g daemon off;
