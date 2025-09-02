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
  -v $(pwd)/cert/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/cert/letsencrypt:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/cert/output:/output \
  -v $(pwd)/hook/add-txt.sh:/add-txt.sh \
  -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh \
  -v $(pwd)/hook/deploy-hook.sh:/deploy-hook.sh \
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
  --deploy-hook "/deploy-hook.sh"
```

### List all certificates
```sh
docker run --rm -it \
  -v $(pwd)/cert/letsencrypt:/etc/letsencrypt \
  certbot/certbot certificates
```

### Renew certificates

```sh
# Renew all certificates that are close to expiry (dry run)
docker run --rm -it \
  -v $(pwd)/cert/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/cert/letsencrypt:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/cert/output:/output \
  -v $(pwd)/hook/add-txt.sh:/add-txt.sh \
  -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh \
  -v $(pwd)/hook/deploy-hook.sh:/deploy-hook.sh \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  certbot/certbot renew \
  --test-cert \
  --dry-run

# Renew all certificates that are close to expiry (actual renewal)
docker run --rm -it \
  -v $(pwd)/cert/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/cert/letsencrypt:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/cert/output:/output \
  -v $(pwd)/hook/add-txt.sh:/add-txt.sh \
  -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh \
  -v $(pwd)/hook/deploy-hook.sh:/deploy-hook.sh \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  certbot/certbot renew \
  --test-cert

# Force renew specific certificate
docker run --rm -it \
  -v $(pwd)/cert/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/cert/letsencrypt:/var/lib/letsencrypt \
  -v $(pwd)/cert/log:/var/log \
  -v $(pwd)/cert/output:/output \
  -v $(pwd)/hook/add-txt.sh:/add-txt.sh \
  -v $(pwd)/hook/remove-txt.sh:/remove-txt.sh \
  -v $(pwd)/hook/deploy-hook.sh:/deploy-hook.sh \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  certbot/certbot renew \
  --test-cert \
  --cert-name my-school.online \
  --force-renewal

```