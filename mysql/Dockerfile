FROM debian:jessie

MAINTAINER keopx <keopx@keopx.net>

ENV DEBIAN_FRONTEND noninteractive

# Set repositories
RUN \
  echo "deb http://ftp.de.debian.org/debian/ jessie main non-free contrib\n" > /etc/apt/sources.list && \
  echo "deb-src http://ftp.de.debian.org/debian/ jessie main non-free contrib\n" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ jessie/updates main contrib non-free\n" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list


# Update repositories cache and distribution
RUN apt-get -qq update && apt-get -qqy upgrade

# Install MySQL server.
RUN apt-get -qy install mysql-client mysql-server 

# Cleanup some things
RUN apt-get -q autoclean && \
  rm -rf /var/lib/apt/lists/*

# Make mysql listen on the outside
RUN sed -i "s/^myisam-recover/myisam-recover-options/" /etc/mysql/my.cnf
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

# Volume for MySQL data
VOLUME /var/lib/mysql

# MySQL start command.
COPY scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]