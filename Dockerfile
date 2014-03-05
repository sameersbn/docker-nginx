FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-mark hold initscripts && apt-get upgrade -y && apt-get clean # 20140305

# essentials
RUN apt-get install -y vim curl wget sudo net-tools pwgen && \
	apt-get install -y logrotate supervisor openssh-server && \
	apt-get clean

# build tools
# RUN apt-get install -y gcc make && apt-get clean

# image specific
RUN apt-get install -y nginx php5-common php5-cli php5-fpm
RUN apt-get update && apt-get upgrade -y && apt-get clean # 20140225

ADD resources/ /nginx-php/
RUN chmod 755 /nginx-php/setup/install && /nginx-php/setup/install

ADD authorized_keys /root/.ssh/
RUN mv /nginx-php/.vimrc /nginx-php/.bash_aliases /root/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root -R /root

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-n"]
