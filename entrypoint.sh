#!/bin/bash
set -e

[[ $DEBUG == true ]] && set -x

create_log_dir() {
  mkdir -p ${NGINX_LOG_DIR}
  chmod -R 0755 ${NGINX_LOG_DIR}
  chown -R ${NGINX_USER}:root ${NGINX_LOG_DIR}
}

create_tmp_dir(){
  mkdir -p ${NGINX_TEMP_DIR}
  chown -R root:root ${NGINX_TEMP_DIR}
}

create_siteconf_dir() {
  mkdir -p ${NGINX_SITECONF_DIR}
  chmod -R 755 ${NGINX_SITECONF_DIR}
}

create_log_dir
create_tmp_dir
create_siteconf_dir

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
  echo "Starting nginx..."
  exec $(which nginx) -c /etc/nginx/nginx.conf -g "daemon off;" ${EXTRA_ARGS}
else
  exec "$@"
fi
