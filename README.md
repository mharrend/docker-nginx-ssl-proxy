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
| LISTEN_IP      | 172.15.0.2             | Port listen by proxied server|
| LISTEN_PORT    | 8080                   | Port listen by proxied server| 
| LOG\_FILE      | /var/log/nginx/subdom1.access.log  | Path for log file|

* E.g., a proper setting of the first domain could be
```
docker run ... \
-e DOMAIN1_DOMAIN_NAME= subdomain1.domain.com \
-e DOMAIN1_SSL_CERT=/etc/nginx/ssl-cert/subdom1.crt \
-e DOMAIN1_SSL_KEY=/etc/nginx/ssl-cert/subdom1.key \
-e DOMAIN1_LISTEN_PORT=8080 \
-e DOMAIN1_LOG_FILE=/var/log/nginx/subdom1.access.log \
...
```
Notes:
* Only proxying to servers listening on localhost port / sitting on the same host should be used, since http connections to non-localhost machines can be a security flaw.

## Data volume
* For a better customisation a data volume is added.
* The data/conf.d subfolder is mapped to the /etc/nginx/conf.d folder, so that it is easy to adjust the nginx config.
* The data/ssl-cert subfolder is linked to the /etc/nginx/ssl-cert folder, so that it can be justed to store the SSL certificates and keys.


## More details
* Use of NGinx alpine image to reduce image size.
* The /etc/nginx/conf.d/default.conf file will contain:
```
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```
* The sub sites will be defined in a /etc/nginx/conf.d/%DOMAIN_NAME% file in the following way
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

### Copy SSL certificate and key to docker container
* The easiest way to copy the SSL certificate and key to the docker container is to make use of the data/ssl-cert container:
```
cp /tmp/HOST/ssl.crt /HOST/data/ssl-cert/subdom1.crt
cp /tmp/HOST/ssl.key /HOST/data/ssl-cert/subdom1.key
```
* Another solution is to to copy the SSL certificate and key directly to the docker container via
```
docker cp /tmp/HOST/ssl.crt [ContainerID]:/etc/nginx/subdom1.crt
docker cp /tmp/HOST/ssl.key [ContainerID]:/etc/nginx/subdom1.key
```

### Start docker container
```
docker run --restart=always  -dt -p 80:80 -p 443:443 \
-v /home/nginx:/data \
-e DOMAIN1_DOMAIN_NAME= subdomain1.domain.com \
-e DOMAIN1_SSL_CERT=/etc/nginx/ssl-cert/subdom1.crt \
-e DOMAIN1_SSL_KEY=/etc/nginx/ssl-cert/subdom1.key \
-e DOMAIN1_LISTEN_PORT=8080 \
-e DOMAIN1_LOG_FILE=/var/log/nginx/subdom1.access.log  \
nginx-ssl-proxy:alpine
```

