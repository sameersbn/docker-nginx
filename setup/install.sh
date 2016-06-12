#!/bin/bash
set -e

NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
NGINX_RTMP_MODULE_DOWNLOAD_URL="https://github.com/arut/nginx-rtmp-module/archive/v${RTMP_VERSION}.tar.gz"
NGX_PAGESPEED_DOWNLOAD_URL="https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.tar.gz"
PSOL_DOWNLOAD_URL="https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz"
LIBAV_DOWNLOAD_URL="https://libav.org/releases/libav-${LIBAV_VERSION}.tar.gz"

RUNTIME_DEPENDENCIES="libssl1.0.0 libxslt1.1 libpcre++ libgd3 libxpm4 libgeoip1"
BUILD_DEPENDENCIES="make gcc g++ libssl-dev libxslt-dev libpcre++-dev libgd2-xpm-dev libgeoip-dev"

download_and_extract() {
  src=${1}
  dest=${2}
  tarball=$(basename ${src})

  if [ ! -f ${NGINX_SETUP_DIR}/sources/${tarball} ]; then
    echo "Downloading ${tarball}..."
    mkdir -p ${NGINX_SETUP_DIR}/sources/
    wget ${src} -O ${NGINX_SETUP_DIR}/sources/${tarball}
  fi

  echo "Extracting ${tarball}..."
  mkdir ${dest}
  tar -zxf ${NGINX_SETUP_DIR}/sources/${tarball} --strip=1 -C ${dest}
  rm -rf ${NGINX_SETUP_DIR}/sources/${tarball}
}

# prepare rtmp module support
${WITH_RTMP} && {
  EXTRA_ARGS="${EXTRA_ARGS} --add-module=${NGINX_SETUP_DIR}/nginx-rtmp-module"
  download_and_extract "${NGINX_RTMP_MODULE_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/nginx-rtmp-module"
  ${BUILD_LIBAV} && {
    echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
    RUNTIME_DEPENDENCIES="$RUNTIME_DEPENDENCIES libfdk-aac0 libx264-142"
    BUILD_DEPENDENCIES="$BUILD_DEPENDENCIES yasm libfdk-aac-dev libx264-dev"
    download_and_extract "${LIBAV_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/libav"
  } || {
    RUNTIME_DEPENDENCIES="$RUNTIME_DEPENDENCIES libav-tools"
  }
}

# prepare pagespeed module support
${WITH_PAGESPEED} && {
  EXTRA_ARGS="${EXTRA_ARGS} --add-module=${NGINX_SETUP_DIR}/ngx_pagespeed"
  download_and_extract "${NGX_PAGESPEED_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/ngx_pagespeed"
  download_and_extract "${PSOL_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/ngx_pagespeed/psol"
}

# enable debug support
${WITH_DEBUG} && {
  EXTRA_ARGS="${EXTRA_ARGS} --with-debug"
}

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ${RUNTIME_DEPENDENCIES} ${BUILD_DEPENDENCIES}

# build libav
${WITH_RTMP} && ${BUILD_LIBAV} && {
  cd ${NGINX_SETUP_DIR}/libav
  ./configure \
    --prefix=/usr \
    --disable-debug \
    --disable-static \
    --enable-shared \
    --enable-nonfree \
    --enable-gpl \
    --enable-libx264 \
    --enable-libfdk-aac
  make -j$(nproc) && make install
}

# build nginx with modules enabled at build time
download_and_extract "${NGINX_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/nginx"
cd ${NGINX_SETUP_DIR}/nginx

./configure \
  --prefix=/usr/share/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --sbin-path=/usr/sbin \
  --http-log-path=/var/log/nginx/access.log \
  --error-log-path=/var/log/nginx/error.log \
  --lock-path=/var/lock/nginx.lock \
  --pid-path=/run/nginx.pid \
  --http-client-body-temp-path=${NGINX_TEMP_DIR}/body \
  --http-fastcgi-temp-path=${NGINX_TEMP_DIR}/fastcgi \
  --http-proxy-temp-path=${NGINX_TEMP_DIR}/proxy \
  --http-scgi-temp-path=${NGINX_TEMP_DIR}/scgi \
  --http-uwsgi-temp-path=${NGINX_TEMP_DIR}/uwsgi \
  --with-pcre-jit \
  --with-ipv6 \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_realip_module \
  --with-http_auth_request_module \
  --with-http_addition_module \
  --with-http_dav_module \
  --with-http_geoip_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_image_filter_module \
  --with-http_v2_module \
  --with-http_sub_module \
  --with-http_xslt_module \
  --with-stream \
  --with-stream_ssl_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-threads \
  ${EXTRA_ARGS}

make -j$(nproc) && make install

# copy rtmp stats template
${WITH_RTMP} && {
  cp ${NGINX_SETUP_DIR}/nginx-rtmp-module/stat.xsl /usr/share/nginx/html/
}

# create default configuration
mkdir -p /etc/nginx/sites-enabled
cat > /etc/nginx/sites-enabled/default <<EOF
server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  server_name localhost;

  root /usr/share/nginx/html;
  index index.html index.htm;

  location / {
    try_files \$uri \$uri/ =404;
  }

  location /stat {
    rtmp_stat all;
    rtmp_stat_stylesheet stat.xsl;
  }

  location /stat.xsl {
    root html;
  }

  location /control {
    rtmp_control all;
  }

  error_page  500 502 503 504 /50x.html;
    location = /50x.html {
    root html;
  }
}
EOF

# cleanup
apt-get purge -y --auto-remove ${BUILD_DEPENDENCIES}
rm -rf ${NGINX_SETUP_DIR}/{nginx,nginx-rtmp-module,ngx_pagespeed,libav}
rm -rf /var/lib/apt/lists/*
