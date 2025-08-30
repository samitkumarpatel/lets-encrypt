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