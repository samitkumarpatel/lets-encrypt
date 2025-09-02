#!/bin/sh
# add-txt.sh
echo "Automated DNS Auth Hook - Creating TXT record via Azure DNS API"
echo "CERTBOT_VALIDATION: $CERTBOT_VALIDATION"
echo "CERTBOT_DOMAIN: $CERTBOT_DOMAIN"
echo "CERTBOT_TOKEN: $CERTBOT_TOKEN"

# Use Python script to create TXT record
python3 -c "
import os
import requests
import time

# Get Azure access token
token_resp = requests.post(
    f'https://login.microsoftonline.com/{os.environ['ARM_TENANT_ID']}/oauth2/v2.0/token',
    data={
        'client_id': os.environ['ARM_CLIENT_ID'],
        'scope': 'https://management.azure.com/.default',
        'client_secret': os.environ['ARM_CLIENT_SECRET'],
        'grant_type': 'client_credentials'
    }
)

access_token = token_resp.json().get('access_token')

if not access_token:
    print('Failed to get access token')
    exit(1)

print('Creating TXT record...')

# Create DNS TXT record
dns_resp = requests.put(
    f'https://management.azure.com/subscriptions/{os.environ['ARM_SUBSCRIPTION_ID']}/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/_acme-challenge?api-version=2018-05-01',
    headers={
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    },
    json={
        'properties': {
            'TTL': 60,
            'TXTRecords': [{'value': [os.environ['CERTBOT_VALIDATION']]}]
        }
    }
)

status = 'created' if dns_resp.status_code in [200, 201] else 'failed'
print(f'TXT record {status}: {dns_resp.status_code}')

# Wait for DNS propagation
time.sleep(30)
"
