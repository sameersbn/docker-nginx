#!/bin/bash
set -e

# create temp dir
mkdir -p /var/lib/nginx
chown -R root:root /var/lib/nginx

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
