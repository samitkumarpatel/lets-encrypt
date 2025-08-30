# letsencrypt


### dns
```sh
#Print ns
dig NS my-school.online  +nssearch
#OR
nslookup -type=ns fullstack1o1.net

#fetch TXT record
dig +short TXT test-txt.fullstack1o1.net
#OR
nslookup -type=txt test-txt.fullstack1o1.net
```

### help
```sh
#To get help around certbot command
docker run --rm certbot/certbot -h all
```

### Generate ssl/tls from let's encrypt staging env in non-interactive way.

```sh

docker run --rm -it \
  -v $(pwd)/cert:/etc/letsencrypt \
  -v $(pwd)/cert:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/hook/add-txt.sh:/add-txt.sh \
  -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  certbot/certbot certonly \
  --test-cert \
  --manual \
  --manual-auth-hook "/add-txt.sh" \
  --manual-cleanup-hook "/remove-txt.sh" \
  --preferred-challenges dns \
  -d "*.my-school.online" \
  --agree-tos \
  --no-eff-email \
  -m xxxxxx@gmail.com \
  -n

```

### Add a TXT record in azure dns zone

```sh
export ARM_CLIENT_ID="xxxxxx"
export ARM_CLIENT_SECRET="xxxxxxx"
export ARM_TENANT_ID="xxxxxxxxxxxxxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="xxxxxxxxxxxxxxxxxxxx"

accessToken=$(curl -X POST "https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/v2.0/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=$ARM_CLIENT_ID&scope=https://management.azure.com/.default&client_secret=$ARM_CLIENT_SECRET&grant_type=client_credentials" | jq -r '.access_token')



curl -X PUT \
  -H "Authorization: Bearer $accessToken" \
  -H "Content-Type: application/json" \
  "https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/_test_cli?api-version=2018-05-01" \
  -d '{ 
        "properties": {
          "TTL": 3600,
          "TXTRecords": [
            {
              "value": ["HelloCLI_1"]
            }
          ]
        }
      }'

```