FROM sameersbn/debian:jessie.20141001
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
 && rm -rf /var/lib/apt/lists/* # 20140918

ADD install /install
RUN chmod 755 /install
RUN /install

ADD php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

EXPOSE 80
EXPOSE 443
EXPOSE 1935

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
