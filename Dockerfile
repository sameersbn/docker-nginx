FROM sameersbn/ubuntu:14.04.20160504
MAINTAINER sameer@damagehead.com

ENV RTMP_VERSION=1.1.7 \
    NPS_VERSION=1.9.32.10 \
    LIBAV_VERSION=11.4 \
    NGINX_VERSION=1.8.1 \
    NGINX_USER=www-data \
    NGINX_SITECONF_DIR=/etc/nginx/sites-enabled \
    NGINX_LOG_DIR=/var/log/nginx \
    NGINX_TEMP_DIR=/var/lib/nginx \
    NGINX_SETUP_DIR=/var/cache/nginx

ARG WITH_RTMP=true
ARG BUILD_LIBAV=false
ARG WITH_PAGESPEED=true
ARG WITH_DEBUG=false

COPY setup/ ${NGINX_SETUP_DIR}/
RUN bash ${NGINX_SETUP_DIR}/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp 443/tcp 1935/tcp
VOLUME ["${NGINX_SITECONF_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/nginx"]
