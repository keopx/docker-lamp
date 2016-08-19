FROM debian:jessie

MAINTAINER keopx <keopx@keopx.net>

#
# Step 1: Installation
#

# Set frontend. We'll clean this later on!
ENV DEBIAN_FRONTEND noninteractive

ENV LOCALE es_ES.UTF-8

# Set repositories
RUN \
  echo "deb http://ftp.de.debian.org/debian/ jessie main non-free contrib\n" > /etc/apt/sources.list && \
  echo "deb-src http://ftp.de.debian.org/debian/ jessie main non-free contrib\n" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ jessie/updates main contrib non-free\n" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
  
# Update repositories cache and distribution
RUN apt-get -qq update && apt-get -qqy upgrade

# Install some basic tools needed for deployment
RUN apt-get -yqq install \
  apt-utils \
  build-essential \
  debconf-utils \
  debconf \
  mysql-client \
  locales \
  curl \
  wget \  
  unzip \
  patch \
  rsync \
  vim \
  openssh-client \
  git
  
# Configure Dotdeb sources
RUN \
  wget -O - http://www.dotdeb.org/dotdeb.gpg | apt-key add - && \
  echo "deb http://packages.dotdeb.org jessie all\n" > /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list && \
  apt-get -qq update


# Install PHP7 with Xdebug (dev environment)
RUN apt-get -yqq install \
  php7.0 		\
  php7.0-curl 		\
  php7.0-dev 		\
  php7.0-gd 		\
  php7.0-intl 		\
  php7.0-json 		\
  php7.0-mcrypt 	\
  php7.0-mysql		\
  php7.0-apcu		\
  php7.0-memcached 	\
  php7.0-xdebug		\
  libapache2-mod-php7.0

# Install Apache web server
RUN apt-get -yqq install apache2-mpm-prefork

# Install ssmtp MTA
RUN apt-get -yqq install ssmtp

# Install memcached service
# RUN apt-get -yqq install memcached

#
# Step 2: Configuration
#

# Disable by default xdebug. Use docker-compose to add file.
RUN phpdismod xdebug

# Remove all sites enabled
RUN rm /etc/apache2/sites-enabled/*

# Disable default ssl site
RUN a2dissite default-ssl

# Configure needed apache modules and disable default site
RUN a2enmod		\
  access_compat		\
  actions		\
  alias			\
  auth_basic		\
  authn_core		\
  authn_file		\
  authz_core		\
  authz_groupfile	\
  authz_host 		\
  authz_user		\
  autoindex		\
  dir			\
  env 			\
  expires 		\
  filter 		\
  mime 			\
  negotiation 		\
  php7.0 		\
  mpm_prefork 		\
  reqtimeout 		\
  rewrite 		\
  setenvif 		\
  status 		\
  && a2dismod cgi
  
# Install composer (latest version)
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

### Install DRUSH (latest stable) ###
# Run this in your terminal to get the latest project version:
RUN curl http://files.drush.org/drush.phar -L -o drush.phar
# Accessing from anywhere on your system:
RUN mv drush.phar /usr/local/bin/drush
# Apply executable permissions on the downloaded file:
RUN chmod +x /usr/local/bin/drush
# Copy configuration files to user home directory:
RUN drush init -y

### DRUSH Faster way:
#RUN composer global require drush/drush:@stable

### Install DRUPAL CONSOLE (latest version) ###
# Run this in your terminal to get the latest project version:
RUN curl https://drupalconsole.com/installer -L -o drupal.phar
# Accessing from anywhere on your system:
RUN mv drupal.phar /usr/local/bin/drupal
# Apply executable permissions on the downloaded file:
RUN chmod +x /usr/local/bin/drupal
# Copy configuration files to user home directory:
RUN drupal init --override

### DRUPAL CONSOLE Faster way:
#RUN composer global require drupal/console:@stable

#
# Step 3: Clean the system
#

# Cleanup some things
RUN apt-get -q autoclean && \
  rm -rf /var/lib/apt/lists/*

#
# Step 4: Run
#

# Working dir
WORKDIR /var/www

# Volume for Apache2 data
VOLUME /var/www

COPY scripts/apache2-foreground /usr/bin/

EXPOSE 80 443

CMD ["apache2-foreground"]