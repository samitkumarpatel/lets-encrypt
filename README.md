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

#### Store cert in specific path
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
  -n \
  --cert-path $(pwd)/cert/cert.pem \
  --key-path $(pwd)/cert/privkey.pem \
  --fullchain-path $(pwd)/cert/fullchain.pem \
  --chain-path $(pwd)/cert/chain.pem
```
> Best Practice will be

```sh
docker run --rm -it \
  -v $(pwd)/cert:/etc/letsencrypt \
  -v $(pwd)/cert:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/cert:/output \
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
  -n \
  --deploy-hook "cp /etc/letsencrypt/live/*/cert.pem /output/ && cp /etc/letsencrypt/live/*/privkey.pem /output/ && cp /etc/letsencrypt/live/*/fullchain.pem /output/ && cp /etc/letsencrypt/live/*/chain.pem /output/"
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

### Remove TXT record

```sh
curl -X DELETE \
  -H "Authorization: Bearer $accessToken" \
  "https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/personal/providers/Microsoft.Network/dnsZones/my-school.online/TXT/test-txt?api-version=2018-05-01"
```

### Debug Certificate

```sh

sudo openssl x509 -in cert.pem -text -noout
```

### Renew certificates

```sh
# Renew all certificates that are close to expiry (dry run)
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
  certbot/certbot renew \
  --test-cert \
  --dry-run

# Renew all certificates that are close to expiry (actual renewal)
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
  certbot/certbot renew \
  --test-cert

# Force renew specific certificate
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
  certbot/certbot renew \
  --test-cert \
  --cert-name my-school.online \
  --force-renewal

# List all certificates
docker run --rm -it \
  -v $(pwd)/cert:/etc/letsencrypt \
  certbot/certbot certificates
```

### Automated renewal with cron

```sh
# Add to crontab for automatic renewal (runs twice daily)
# Run: crontab -e
# Add this line:
0 */12 * * * cd /path/to/your/lets-encrypt && docker run --rm -v $(pwd)/cert:/etc/letsencrypt -v $(pwd)/cert:/var/lib/letsencrypt -v $(pwd)/cert/log:/var/log -v $(pwd)/hook/add-txt.sh:/add-txt.sh -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh -e ARM_CLIENT_ID=$ARM_CLIENT_ID -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET -e ARM_TENANT_ID=$ARM_TENANT_ID -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID certbot/certbot renew --quiet
```