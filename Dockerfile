FROM sameersbn/ubuntu:14.04.20150220
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
 && rm -rf /var/lib/apt/lists/* # 20150220

ADD install /install
RUN chmod 755 /install
RUN /install

ADD start /start
RUN chmod 755 /start

ADD nginx.conf.example /etc/nginx/nginx.conf
ADD php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

EXPOSE 80
EXPOSE 443
EXPOSE 1935

VOLUME ["/var/cache/ngx_pagespeed"]

CMD ["/start"]
