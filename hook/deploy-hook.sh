#!/bin/sh
# Copy certificates to output directory
CURRENT_DATE_TIME=$(date +"%Y%m%d%H%M%S")
echo "Deploy Hook - Copying certificates to /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME"
mkdir -p /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME

cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/cert.pem /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME/cert.pem
cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME/privkey.pem
cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME/fullchain.pem
cp /etc/letsencrypt/live/$CERTBOT_DOMAIN/chain.pem /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME/chain.pem

echo "Generate pfx file"
openssl pkcs12 \
    -export \
    -out /output/$CERTBOT_DOMAIN/$CURRENT_DATE_TIME/cert.pfx \
    -inkey /etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem \
    -in /etc/letsencrypt/live/$CERTBOT_DOMAIN/cert.pem \
    -certfile /etc/letsencrypt/live/$CERTBOT_DOMAIN/chain.pem \
    -passout pass:"${PFX_PASSWORD:-}"