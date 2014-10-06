#!/bin/bash
set -e

# fix permissions and ownership of /var/lib/nginx
mkdir -p -m 755 /var/lib/nginx
chown -R root:root /var/lib/nginx

# fix permissions and ownership of /var/cache/ngx_pagespeed
mkdir -p -m 755 /var/cache/ngx_pagespeed
chown -R www-data:www-data /var/cache/ngx_pagespeed

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
