FROM ubuntu:bionic-20180526

LABEL maintainer="sameer@damagehead.com"

ENV RTMP_VERSION=1.2.1 \
    NPS_VERSION=1.11.33.4 \
    LIBAV_VERSION=12.2 \
    NGINX_VERSION=1.12.2 \
    NGINX_USER=www-data \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx \
    NGINX_BUILD_DIR=/var/cache/nginx

ARG BUILD_LIBAV=false

ARG WITH_DEBUG=false

ARG WITH_PAGESPEED=true

ARG WITH_RTMP=true

COPY assets/build/ ${NGINX_BUILD_DIR}/

RUN bash ${NGINX_BUILD_DIR}/install.sh

COPY assets/config/nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp 443/tcp 1935/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/nginx"]
