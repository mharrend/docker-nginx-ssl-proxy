FROM nginx:alpine
MAINTAINER Marco A. Harrendorf <marco.harrendorf@cern.ch>

VOLUME ["/data"]

ADD configs/http.cfg /etc/nginx/sites-enabled/default
ADD configs/ssl-template-part1.cfg /etc/nginx/ssl-template-part1.cfg
ADD configs/ssl-template-part2.cfg /etc/nginx/ssl-template-part2.cfg
ADD configs/ssl-template-part3.cfg /etc/nginx/ssl-template-part3.cfg
ADD bin/prepare-env.sh /prepare-env.sh
RUN chmod +x /prepare-env.sh

RUN apk add --no-cache bash grep bc coreutils

ADD bin/run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
