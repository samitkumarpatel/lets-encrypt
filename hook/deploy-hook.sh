#!/bin/sh
# Copy certificates to output directory
cp /etc/letsencrypt/live/*/cert.pem /output/
cp /etc/letsencrypt/live/*/privkey.pem /output/
cp /etc/letsencrypt/live/*/fullchain.pem /output/
cp /etc/letsencrypt/live/*/chain.pem /output/