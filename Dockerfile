FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get clean # 20130925

RUN apt-get install -y vim nginx php5-common php5-cli php5-fpm supervisor
ADD resources/install /install
ADD resources/nginx.conf /etc/nginx/nginx.conf
ADD resources/sites-available/ /etc/nginx/sites-available/
ADD resources/sites-enabled/ /etc/nginx/sites-enabled/
RUN chmod 755 /install && /install

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-n"]
