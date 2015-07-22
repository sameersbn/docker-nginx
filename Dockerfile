FROM sameersbn/ubuntu:14.04.20150712
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
 && rm -rf /var/lib/apt/lists/*

COPY install /install
RUN chmod 755 /install
RUN /install

COPY start /start
RUN chmod 755 /start

COPY nginx.conf.example /etc/nginx/nginx.conf

EXPOSE 80/tcp 443/tcp 1935/tcp

VOLUME ["/etc/nginx/sites-enabled"]

CMD ["/start"]
