# Docker-NGinx-SSL-Proxy
Dockerized Nginx Proxy for SSL

## USAGE
A basic Nginx Server will be set up which acts as SSL proxy to the specified sub sites.

For each site the following environment variables are parsed and used at the moment:

|   VAR          |    example             | description            |
|----------------|------------------------|------------------------|
| DOMAIN\_NAME   | subdom1.domain.com     | Domain name |
| SSL\_CERT      | /etc/nginx/subdom1.crt | Path to SSL certificate |
| SSL\_KEY       | /etc/nginx/subdom1.key | Path to SSL key |
| LISTEN_PORT    | 8080                   | Port listen by proxied server| 
| LOG\_FILE      | /var/log/nginx/subdom1.access.log  | Path for log file|

Notes:
* Only proxying to servers listening on localhost port / sitting on the same host is implemented, since http connections to non-localhost machines can be a security flaw.

## More details
* Use of NGinx vanilla image to reduce image size.
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
docker build --tag nginx:vanilla github.com/mharrend/docker-nginx-ssl-proxy
```
