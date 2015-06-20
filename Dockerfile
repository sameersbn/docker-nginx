FROM sameersbn/ubuntu:14.04.20150613
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
 && rm -rf /var/lib/apt/lists/* # 20150613

COPY releases/ /tmp/
COPY install /install
RUN chmod 755 /install
RUN /install

COPY start /start
RUN chmod 755 /start

COPY nginx.conf.example /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443
EXPOSE 1935

VOLUME ["/etc/nginx/sites-enabled"]

CMD ["/start"]
