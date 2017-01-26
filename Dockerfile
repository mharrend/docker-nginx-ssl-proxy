FROM nginx:alpine
MAINTAINER Marco A. Harrendorf <marco.harrendorf@cern.ch>

ADD configs/http.cfg /etc/nginx/sites-enabled/default
ADD configs/ssl-template.cfg /etc/nginx/ssl-template.cfg
ADD bin/prepare-env.sh /prepare-env.sh

RUN /prepare-env.sh 
ENTRYPOINT ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
