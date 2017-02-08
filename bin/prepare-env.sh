#!/bin/sh
# Found domains: cut gets only first field, sort delivers only unique entries
export FOUND_DOMAINS=`env | grep -o "DOMAIN[0-9]*" | cut -d_ -f1 | sort -u`
echo "Following domains were found:"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  TMP_DOMAIN_NAME="${FOUND_DOMAIN}_DOMAIN_NAME"
  echo $FOUND_DOMAIN, ${!TMP_DOMAIN_NAME}
done

# Setting up site config for each domain
echo "Setting up site config for each domain"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  TMP_DOMAIN_NAME="${FOUND_DOMAIN}_DOMAIN_NAME"
  TMP_SSL_CERT="${FOUND_DOMAIN}_SSL_CERT"
  TMP_SSL_KEY="${FOUND_DOMAIN}_SSL_KEY"
  TMP_LISTEN_PORT="${FOUND_DOMAIN}_LISTEN_PORT"
  TMP_LOG_FILE="${FOUND_DOMAIN}_LOG_FILE"
  
  echo "For the domain ", TMP_DOMAIN_NAME
  echo "the following config will be used:"
  echo "SSL_CERT: ", TMP_SSL_CERT
  echo "SSL_KEY: ", TMP_SSL_KEY
  echo "LISTEN_PORT: ", TMP_LISTEN_PORT
  echo "LOG_FILE: ", TMP_LOG_FILE
  
  cp /etc/nginx/ssl-template.cfg /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%DOMAIN_NAME%|${TMP_DOMAIN_NAME}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%SSL_CERT%|${TMP_SSL_CERT}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%SSL_KEY%|${TMP_SSL_KEY}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%LISTEN_PORT%|${TMP_LISTEN_PORT}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%LOG_FILE%|${TMP_LOG_FILE}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  echo "Config set up for ", $TMP_DOMAIN_NAME
done
