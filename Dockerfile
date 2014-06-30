FROM sameersbn/ubuntu:12.04.20140628
MAINTAINER sameer@damagehead.com

RUN apt-get update && \
		apt-get install -y make libpcre++-dev libssl-dev libxslt-dev libgd2-xpm-dev libgeoip-dev ffmpeg && \
		apt-get clean # 20140625

RUN	alias make="make -j$(awk '/^processor/ { N++} END { print N }' /proc/cpuinfo)" && \
		mkdir /tmp/nginx-rtmp-module && \
		wget https://github.com/arut/nginx-rtmp-module/archive/v1.1.4.tar.gz -O - | tar -zxf - --strip=1 -C /tmp/nginx-rtmp-module && \
		mkdir -p /tmp/nginx && \
		wget http://nginx.org/download/nginx-1.6.0.tar.gz -O - | tar -zxf - -C /tmp/nginx --strip=1 && \
		cd /tmp/nginx && \
		./configure --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin \
			--http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log \
			--lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid \
			--http-client-body-temp-path=/var/lib/nginx/body \
			--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
			--http-proxy-temp-path=/var/lib/nginx/proxy \
			--http-scgi-temp-path=/var/lib/nginx/scgi \
			--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
			--with-pcre-jit --with-ipv6 --with-http_ssl_module \
			--with-http_stub_status_module --with-http_realip_module \
			--with-http_addition_module --with-http_dav_module --with-http_geoip_module \
			--with-http_gzip_static_module --with-http_image_filter_module \
			--with-http_spdy_module --with-http_sub_module --with-http_xslt_module \
			--with-mail --with-mail_ssl_module --add-module=/tmp/nginx-rtmp-module && \
		make && make install && mkdir -p /var/lib/nginx && \
		cp /tmp/nginx-rtmp-module/stat.xsl /usr/share/nginx/html/ && \
		rm -rf /tmp/nginx /tmp/nginx-rtmp-module

ADD nginx.conf /etc/nginx/nginx.conf
ADD php5-fpm.conf /etc/nginx/conf.d/php5-fpm.conf

EXPOSE 80
EXPOSE 443
EXPOSE 1935

CMD ["/usr/sbin/nginx"]
