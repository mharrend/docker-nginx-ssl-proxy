#!/bin/bash

echo "Removing default nginx conf.d config and replace with data container"
if [ -f /data/default.conf ] ; then
  echo "Removing conf.d"
  rm -rf /etc/nginx/conf.d
else
  echo "Moving conf.d to data"
  mv /etc/nginx/conf.d/* /data/
fi

echo "Linking data directory"
ln -s /data /etc/nginx/conf.d

# Found domains: cut gets only first field, sort delivers only unique entries
export FOUND_DOMAINS=`env | grep -o "DOMAIN[0-9]*" | cut -d_ -f1 | sort -u`
echo "Following domains were found:"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  if [ "$FOUND_DOMAIN" = "DOMAIN" ];
  then
    continue
  fi
  TMP_DOMAIN_NAME="${FOUND_DOMAIN}_DOMAIN_NAME"
  echo $FOUND_DOMAIN ${!TMP_DOMAIN_NAME}
done



# Setting up site config for each domain
echo "Setting up site config for each domain"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  if [ "$FOUND_DOMAIN" = "DOMAIN" ];
  then
    continue
  fi
  
  TMP_DOMAIN_NAME="${FOUND_DOMAIN}_DOMAIN_NAME"
  TMP_SSL_CERT="${FOUND_DOMAIN}_SSL_CERT"
  TMP_SSL_KEY="${FOUND_DOMAIN}_SSL_KEY"
  TMP_LISTEN_PORT="${FOUND_DOMAIN}_LISTEN_PORT"
  TMP_LOG_FILE="${FOUND_DOMAIN}_LOG_FILE"
  
  echo "For the domain " ${!TMP_DOMAIN_NAME}
  echo "the following config will be used:"
  echo "SSL_CERT: " ${!TMP_SSL_CERT}
  echo "SSL_KEY: " ${!TMP_SSL_KEY}
  echo "LISTEN_PORT: " ${!TMP_LISTEN_PORT}
  echo "LOG_FILE: " ${!TMP_LOG_FILE}
  
  cp /etc/nginx/ssl-template-part1.cfg /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  echo "    server_name "  ${!TMP_DOMAIN_NAME} ";"      >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo ""                                               >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "    ssl_certificate "  ${!TMP_SSL_CERT} ";"     >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME} 
  echo "    ssl_certificate_key "  ${!TMP_SSL_KEY} ";"  >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  cat /etc/nginx/ssl-template-part2.cfg                 >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  echo ""                                               >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "    access_log "  ${!TMP_LOG_FILE} ";"          >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo ""                                               >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  cat /etc/nginx/ssl-template-part3.cfg                 >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  echo "      proxy_pass          http://localhost:"${!TMP_LISTEN_PORT} ";"    >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "      proxy_read_timeout  90;"                                         >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo ""                                                                      >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "      proxy_redirect      http://localhost:"${!TMP_LISTEN_PORT}" https://"${!TMP_DOMAIN_NAME} ";"  >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "    }"                                                                 >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  echo "  }"                                                                   >> /etc/nginx/conf.d/${!TMP_DOMAIN_NAME}
  
  echo "Config set up for " ${!TMP_DOMAIN_NAME}
  echo ""
done
