#!/bin/sh
# add-txt.sh
echo "Manual DNS Auth Hook"
echo "Please create a TXT record:"
echo "_acme-challenge.$CERTBOT_DOMAIN"
echo "with value:"
echo "CERTBOT_VALIDATION: $CERTBOT_VALIDATION"
echo "CERTBOT_DOMAIN: $CERTBOT_DOMAIN"
echo "CERTBOT_TOKEN: $CERTBOT_TOKEN"
echo "Press ENTER after you have created the record and it has propagated."
#read -r
