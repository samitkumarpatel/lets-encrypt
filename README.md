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
  -e PFX_PASSWORD=helloWorld123 \
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

### Upload to / Download from -  azure storage

```sh

sudo chown -R samit:samit cert

# Set the subscription context after login
az account set --subscription $ARM_SUBSCRIPTION_ID

az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Generate pfx - as some of the SAS service need that
#Why?

#.pem files separate the private key and certificate chain.
#Azure requires them bundled in a PKCS#12 (.pfx) archive.
#The PFX contains:
# Your private key (privkey.pem), Your certificate (cert.pem), The chain (chain.pem)

openssl pkcs12 -export \
  -out certificate.pfx \
  -inkey privkey.pem \
  -in cert.pem \
  -certfile chain.pem

# Set variables
STORAGE_ACCOUNT="azstrogeu001"
CONTAINER_NAME="ssl"
LOCAL_PATH="$(pwd)/cert"

# Upload certificate from output directory
az storage blob upload-batch \
  --account-name $STORAGE_ACCOUNT \
  --destination $CONTAINER_NAME/output \
  --source $LOCAL_PATH/output \
  --overwrite \
  --pattern "*"

# zip the letsencrypt folder
tar -czf letsencrypt.tar.gz \
  --preserve-permissions \
  --same-owner \
  cert/letsencrypt

# Upload zip to blob store
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --file letsencrypt.tar.gz \
  --name letsencrypt.tar.gz \
  --overwrite


# Download certificate to be used for somewhere
az storage blob download-batch \
  --account-name $STORAGE_ACCOUNT \
  --destination </path/to/dest> \
  --source $CONTAINER_NAME/output \
  --pattern "*"

# Download zip before any renewal process
az storage blob download \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --name letsencrypt.tar.gz \
  --file letsencrypt.tar.gz

# Uzip
tar -xzf letsencrypt.tar.gz \
  --preserve-permissions \
  --same-owner \
  cert/
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
  -e PFX_PASSWORD=helloWorld123 \
  certbot/certbot renew \
  --test-cert

# Force renew specific certificate
CERTBOT_DOMAIN=my-school.online

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
  -e PFX_PASSWORD=helloWorld123 \
  -e CERTBOT_DOMAIN=$CERTBOT_DOMAIN \
  certbot/certbot renew \
  --test-cert \
  --cert-name $CERTBOT_DOMAIN \
  --force-renewal

```