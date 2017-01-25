FROM nginx:alpine
MAINTAINER Marco A. Harrendorf <marco.harrendorf@cern.ch>

ADD configs/http.cfg /etc/nginx/sites-enabled/default
ADD bin/prepare-env.sh /prepare-env.sh
ADD bin/run.sh /run.sh

ENTRYPOINT "/run.sh"

EXPOSE 80 443
