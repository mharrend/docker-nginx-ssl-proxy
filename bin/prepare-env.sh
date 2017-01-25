#!/bin/bash
# Found domains: cut gets only first field, sort delivers only unique entries
export FOUND_DOMAINS=`env | grep "DOMAIN" | cut -d_ -f1 | sort -u`
echo "Following domains were found:"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  echo $FOUND_DOMAIN, ${FOUND_DOMAIN}_NAME
done

# Setting up site config for each domain
echo "Setting up site config for each domain"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  cp /etc/nginx/ssl-template.cfg /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%DOMAIN_NAME%|${{FOUND_DOMAIN}_NAME}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%SSL_CERT%|${{FOUND_DOMAIN}_SSL_CERT}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%SSL_KEY%|${{FOUND_DOMAIN}_SSL_KEY}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%LISTEN_PORT%|${{FOUND_DOMAIN}_LISTEN_PORT}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  sed -i "s|%LOG_FILE%|${{FOUND_DOMAIN}_LOG_FILE}||g" /etc/nginx/sites-enabled/${FOUND_DOMAIN}_NAME
  echo "Config set up for " ${FOUND_DOMAIN}_NAME
done
