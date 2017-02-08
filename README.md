# Docker-NGinx-SSL-Proxy
Dockerized Nginx Proxy for SSL

## USAGE
* A basic Nginx Server will be set up which acts as SSL proxy to the specified domains / sites.
* You can define different domains / subdomains / sites by making use of docker run -e variables.
* For each domain / subdomain / site, you define the variables by using the variable 
```
DOMAIN[0-1000]_
```
appended by the following keywords:

|   VAR          |    example             | description            |
|----------------|------------------------|------------------------|
| DOMAIN\_NAME   | subdom1.domain.com     | Domain name |
| SSL\_CERT      | /etc/nginx/subdom1.crt | Path to SSL certificate |
| SSL\_KEY       | /etc/nginx/subdom1.key | Path to SSL key |
| LISTEN_PORT    | 8080                   | Port listen by proxied server| 
| LOG\_FILE      | /var/log/nginx/subdom1.access.log  | Path for log file|

* E.g., a proper setting of the first domain could be
```
docker run ... \
-e DOMAIN1_DOMAIN_NAME= subdomain1.domain.com \
-e DOMAIN1_SSL_CERT=/etc/nginx/subdom1.crt \
-e DOMAIN1_SSL_KEY=/etc/nginx/subdom1.key \
-e DOMAIN1_LISTEN_PORT=8080 \
-e DOMAIN1_LOG_FILE=/var/log/nginx/subdom1.access.log \
...
```
Notes:
* Only proxying to servers listening on localhost port / sitting on the same host is implemented, since http connections to non-localhost machines can be a security flaw.

## Data volume
* For a better customisation a data volume is added which will be mapped to the /etc/nginx/sites-enabled folder.
* E.g. you can place your server certificates there to make them available to the docker container.

## More details
* Use of NGinx alpine image to reduce image size.
* The /etc/nginx/sites-enabled/default file will contain:
```
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```
* The sub sites will be defined in a /etc/nginx/sites-enabled/%DOMAIN_NAME% file in the following way
```
server {
    listen 443;
    server_name %DOMAIN_NAME%;

    ssl_certificate           %SSL_CERT%;
    ssl_certificate_key       %SSL_KEY%;

    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    access_log            %LOG_FILE%;

    location / {

      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://localhost:%LISTEN_PORT%;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:%LISTEN_PORT% https://%DOMAIN_NAME%;
    }
  }
```

## Example

### Build docker image
```
docker build --tag nginx-ssl-proxy:alpine github.com/mharrend/docker-nginx-ssl-proxy
```
### Start docker container
```
docker run --restart=always  -dt -p 80:80 -p 443:443 \
-v /home/nginx/sites-enabled:/data \
-e DOMAIN1_DOMAIN_NAME= subdomain1.domain.com \
-e DOMAIN1_SSL_CERT=/etc/nginx/sites-enabled/subdom1.crt \
-e DOMAIN1_SSL_KEY=/etc/nginx/sites-enabled/subdom1.key \
-e DOMAIN1_LISTEN_PORT=8080 \
-e DOMAIN1_LOG_FILE=/var/log/nginx/subdom1.access.log  \
nginx-ssl-proxy:alpine
```
### Copy SSL certificate and key to docker container
* Either make use of the data volume and place the SSL cert and key in the data container or copy them via
```
docker cp /tmp/HOST/ssl.crt [ContainerID]:/etc/nginx/subdom1.crt
docker cp /tmp/HOST/ssl.key [ContainerID]:/etc/nginx/subdom1.key
```
