#!/bin/bash
set -e

# create log dir
mkdir -p ${NGINX_LOG_DIR}
chmod -R 0755 ${NGINX_LOG_DIR}
chown -R ${NGINX_USER}:root ${NGINX_LOG_DIR}

# create temp dir
mkdir -p ${NGINX_TEMP_DIR}
chown -R root:root ${NGINX_TEMP_DIR}

# create site config dir
mkdir -p ${NGINX_SITECONF_DIR}
chmod -R 755 ${NGINX_SITECONF_DIR}
chown -R root:root ${NGINX_SITECONF_DIR}

# allow arguments to be passed to nginx
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == nginx || ${1} == $(which nginx) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch nginx
if [[ -z ${1} ]]; then
  exec $(which nginx) -c /etc/nginx/nginx.conf -g "daemon off;" ${EXTRA_ARGS}
else
  exec "$@"
fi
