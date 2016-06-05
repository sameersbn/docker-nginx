#!/bin/bash
set -e

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

NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
NGINX_RTMP_MODULE_DOWNLOAD_URL="https://github.com/arut/nginx-rtmp-module/archive/v${RTMP_VERSION}.tar.gz"
NGX_PAGESPEED_DOWNLOAD_URL="https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.tar.gz"
PSOL_DOWNLOAD_URL="https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz"
LOADED_LIBAV_URL="https://libav.org/releases/libav-${LIBAV_VERSION}.tar.gz"

APT_PACKAGES="
  gcc g++ make libc6-dev libpcre++-dev libssl-dev libxslt-dev libgd2-xpm-dev
  libgeoip-dev
  perl libssl1.0.0 libxslt1.1 libgd3 libxpm4
  libgeoip1
"

CONGIGURE_ARGS="
  --prefix=/usr/share/nginx
  --conf-path=/etc/nginx/nginx.conf
  --sbin-path=/usr/sbin
  --http-log-path=/var/log/nginx/access.log
  --error-log-path=/var/log/nginx/error.log
  --lock-path=/var/lock/nginx.lock
  --pid-path=/run/nginx.pid
  --http-client-body-temp-path=${NGINX_TEMP_DIR}/body
  --http-fastcgi-temp-path=${NGINX_TEMP_DIR}/fastcgi
  --http-proxy-temp-path=${NGINX_TEMP_DIR}/proxy
  --http-scgi-temp-path=${NGINX_TEMP_DIR}/scgi
  --http-uwsgi-temp-path=${NGINX_TEMP_DIR}/uwsgi
  --with-pcre-jit
  --with-ipv6
  --with-http_ssl_module
  --with-http_stub_status_module
  --with-http_realip_module
  --with-http_addition_module
  --with-http_dav_module
  --with-http_geoip_module
  --with-http_gzip_static_module
  --with-http_image_filter_module
  --with-http_spdy_module
  --with-http_sub_module
  --with-http_xslt_module
  --with-mail
  --with-mail_ssl_module
"

download_and_extract "${NGINX_DOWNLOAD_URL}" "${NGINX_SETUP_DIR}/nginx"

$WITH_RTMP && {
  download_and_extract "${NGINX_RTMP_MODULE_DOWNLOAD_URL}" \
    "${NGINX_SETUP_DIR}/nginx-rtmp-module"
  CONGIGURE_ARGS="$CONGIGURE_ARGS
    --add-module=${NGINX_SETUP_DIR}/nginx-rtmp-module
  "
  $BUILD_LIBAV && {
    cat >> /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu/ trusty multiverse
deb-src http://archive.ubuntu.com/ubuntu/ trusty multiverse
EOF
    download_and_extract "${LOADED_LIBAV_URL}" "${NGINX_SETUP_DIR}/libav"

    APT_PACKAGES="$APT_PACKAGES build-essential yasm libfdk-aac-dev libx264-dev"
  } || {
    APT_PACKAGES="$APT_PACKAGES libav-tools"
  }

}

$WITH_PAGESPEED && {
  download_and_extract "${NGX_PAGESPEED_DOWNLOAD_URL}" \
    "${NGINX_SETUP_DIR}/ngx_pagespeed"
  download_and_extract "${PSOL_DOWNLOAD_URL}" \
    "${NGINX_SETUP_DIR}/ngx_pagespeed/psol"
  CONGIGURE_ARGS="$CONGIGURE_ARGS
    --add-module=${NGINX_SETUP_DIR}/ngx_pagespeed
  "
}

$WITH_DEBUG && {
  CONGIGURE_ARGS="$CONGIGURE_ARGS
    --with-debug
  "
}

apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get install -y $APT_PACKAGES


alias make="make -j$(nproc)"

$WITH_RTMP && $BUILD_LIBAV && {
  cd ${NGINX_SETUP_DIR}/libav
  ./configure \
    --enable-nonfree \
    --enable-gpl \
    --disable-shared \
    --enable-static \
    --enable-libx264 \
    --enable-libfdk-aac
	make && make install
}


cd ${NGINX_SETUP_DIR}/nginx
./configure $CONGIGURE_ARGS
make && make install

$WITH_RTMP && {
  # copy rtmp stats template
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
apt-get purge -y --auto-remove gcc g++ make libc6-dev libpcre++-dev libssl-dev libxslt-dev libgd2-xpm-dev libgeoip-dev
rm -rf ${NGINX_SETUP_DIR}/{nginx,nginx-rtmp-module,ngx_pagespeed,libav}
rm -rf /var/lib/apt/lists/*
