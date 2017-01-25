#!/bin/bash
# Found domains: cut gets only first field, sort delivers only unique entries
export FOUND_DOMAINS=`env | grep "DOMAIN" | cut -d_ -f1 | sort -u`
echo "Following domains were found:"
for FOUND_DOMAIN in $FOUND_DOMAINS
do
  echo $FOUND_DOMAIN
done




# Setting up site config for each domain
echo "Setting up site config for each domain"

