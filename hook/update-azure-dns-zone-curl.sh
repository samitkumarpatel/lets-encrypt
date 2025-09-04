# Get access token from Azure
echo "Getting Azure access token..."
accessToken=$(curl -X POST "https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/v2.0/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=$ARM_CLIENT_ID&scope=https://management.azure.com/.default&client_secret=$ARM_CLIENT_SECRET&grant_type=client_credentials" | jq -r '.access_token')

if [ -z "$accessToken" ] || [ "$accessToken" = "null" ]; then
    echo "Error: Failed to get access token"
    exit 1
fi

echo "Creating TXT record for _acme-challenge.$CERTBOT_DOMAIN..."

# Create TXT record using Azure DNS API
curl -X PUT \
  -H "Authorization: Bearer $accessToken" \
  -H "Content-Type: application/json" \
  "https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/_acme-challenge?api-version=2018-05-01" \
  -d '{ 
        "properties": {
          "TTL": 60,
          "TXTRecords": [
            {
              "value": ["'$CERTBOT_VALIDATION'"]
            }
          ]
        }
      }'

echo "TXT record created. Waiting 30 seconds for DNS propagation..."
sleep 30