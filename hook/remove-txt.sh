#!/bin/sh
# remove-txt.sh
echo "Manual DNS Cleanup Hook"
echo "Remove TXT record _acme-challenge.$CERTBOT_DOMAIN from your DNS provider."

python3 -c "import requests; response = requests.delete('https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/_acme-challenge?api-version=2018-05-01', headers={'Authorization': 'Bearer $accessToken'}); print(f'Status: {response.status_code}')"


