# letsencrypt

### help
```sh
#To get help around certbot command
docker run --rm certbot/certbot -h all
```

### Generate certificate [In test mode]
```sh
docker run -it --rm \                                                                                                                                       125 ↵
  -v $(pwd):/etc/letsencrypt \
  -v $(pwd):/var/lib/letsencrypt \
  certbot/certbot certonly --test-cert --no-eff-email\
  --manual \
  --preferred-challenges dns \
  -d "*.my-school.online" -d "my-school.online" \
  --agree-tos \
  -m xxxxxxx@gmail.com
```

### Generate certificate non-interactive  [In test mode]

```sh
docker run -it --rm \                                                                                                                                         1 ↵
  -v $(pwd):/etc/letsencrypt \
  -v $(pwd):/var/lib/letsencrypt \
  certbot/certbot certonly -n --test-cert --no-eff-email\
  --manual \
  --preferred-challenges dns \
  -d "*.my-school.online" -d "my-school.online" \
  --agree-tos \
  -m xxxxxxxx@gmail.com
```
> PluginError('An authentication script must be provided with --manual-auth-hook when using the manual plugin non-interactively.')
