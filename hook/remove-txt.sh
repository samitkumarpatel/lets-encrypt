#!/bin/sh
# remove-txt.sh
echo "Manual DNS Cleanup Hook"
echo "Remove TXT record _acme-challenge.$CERTBOT_DOMAIN from your DNS provider."

python3 -c "
import os
import requests

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

print('Removing TXT record...')

# Delete DNS TXT record
response = requests.delete(
    f'https://management.azure.com/subscriptions/{os.environ['ARM_SUBSCRIPTION_ID']}/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/_acme-challenge?api-version=2018-05-01',
    headers={'Authorization': f'Bearer {access_token}'}
)

print(f'Status: {response.status_code}')
"

