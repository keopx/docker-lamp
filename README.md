# Native docker-based local environment for Drupal

Use this Docker compose file to spin up local environment for [Drupal](https://wwww.drupal.org) with a *native Docker app*

This docker setup works with **Debian 9**, **Varnish 5.1/5.0/4.0**, **Apache 2.4**, **PHP 7.2/7.1/7.0/5.6**, **MySQL 8.0/5.7/5.6/5.5/** and **Redis 3.2/3.0**. This setup have **Mailhog** and **phpMyAdmin** as helper tools.

This is [keopx](https://www.keopx.net) Docker **[Drupal](https://wwww.drupal.org)** optimized images for apache-php with varnish and MySQL.

---

* [Overview](#overview)
* [Instructions](#instructions)
    * [Usage](#usage)
* [Containers](#containers)
* [Custom settings](#custom-settings)
    * [Varnish](#varnish-1)
        * [drupal-base.vcl for Drupal](#drupal-basevcl-for-drupal)
        * [Environment](#environment)
    * [Apache PHP](#apache-php-1)
        * [Web Data Volume](#web-data-volume)
        * [Apache Virtualhost](#apache-virtualhost)
        * [PHP](#php)
        * [Xdebug](#xdebug)
        * [Drush](#drush)
        * [SSH](#ssh)
        * [Environment](#environment-1)
    * [MySQL](#mysql-1)
        * [MySQL Data Volume](#mysql-data-volume)
        * [Custom my.cnf](#custom-mycnf)
        * [Environment](#environment-2)
    * [Redis](#redis-1)
    * [phpMyAdmin](#phpmyadmin-1)
        * [Environment](#environment-3)
    * [Mailhog](#mailhog-1)

## Overview

The [Drupal](https://wwww.drupal.org) bundle consist of the following containers:

| Container | Version | Service name | Image | Public Port | Enabled by default |
| --------- | ------- | ------------ | ----- | ----------- | ------------------ |
| [Varnish](#varnish) | [5.1](https://github.com/keopx/docker-varnish/blob/master/5.1/)/[5.0](https://github.com/keopx/docker-varnish/blob/master/5.0/)/[4.0](https://github.com/keopx/docker-varnish/blob/master/4.0/) | varnish | <a href="https://hub.docker.com/r/keopx/varnish/" target="_blank">keopx/varnish</a> | 80 | ✓ |
| [Apache PHP](#apache-php) | [7.2](https://github.com/keopx/docker-apache-php/blob/master/7.2/)/[7.1](https://github.com/keopx/docker-apache-php/blob/master/7.1/)/[7.0](https://github.com/keopx/docker-apache-php/blob/master/7.0/)/[5.6](https://github.com/keopx/docker-apache-php/blob/master/5.6/) | apache-php | <a href="https://hub.docker.com/r/keopx/apache-php/" target="_blank">keopx/apache-php</a> | 8008 | ✓ |
| [MySQL](#mysql) | [8.0](https://github.com/keopx/docker-mysql/blob/master/8.0/)/[5.7](https://github.com/keopx/docker-mysql/blob/master/5.7/)/[5.6](https://github.com/keopx/docker-mysql/blob/master/5.6/)/[5.5](https://github.com/keopx/docker-mysql/blob/master/5.5/) | mysql | <a href="https://hub.docker.com/r/keopx/mysql/" target="_blank">keopx/mysql</a> | 3306 | ✓ |
| [Redis](#redis) | [3.2](https://github.com/keopx/docker-redis/blob/master/3.2/)/[3.0](https://github.com/keopx/docker-redis/blob/master/3.0/) | redis | <a href="https://hub.docker.com/r/keopx/redis/" target="_blank">keopx/redis</a> | 6379 | ✓ |
| [phpMyAdmin](#phpmyadmin) | | phpmyadmin | <a href="https://hub.docker.com/r/phpmyadmin/phpmyadmin" target="_blank">phpmyadmin/phpmyadmin</a> |  8080 | ✓ |
| [Mailhog](#mailhog) | | mailhog | <a href="https://hub.docker.com/r/mailhog/mailhog" target="_blank">mailhog/mailhog</a> | 8025 - 1025 | ✓ |


## Instructions

**Feel free to adjust volumes and ports in the compose file for your convenience.**

### Usage

Run:

```bash
$ docker-compose up -d
```

Stop:

```bash
$ docker-compose stop
```
Or down (warning: this command remove volume changes):

```bash
$ docker-compose down
```

#### Run bash

```bash
docker exec -it dockerlamp_web_1 /bin/bash
```

Replace _dockerlamp_web_1_ with _name_ of: 

```bash
docker-compose ps
```

## Containers

### Varnish

Available tags are:

- 5.1, latest ([5.1/Dockerfile](https://github.com/keopx/docker-varnish/blob/master/5.1/Dockerfile))
- 5.0 ([5.0/Dockerfile](https://github.com/keopx/docker-varnish/blob/master/5.0/Dockerfile))
- 4.0 ([4.0/Dockerfile](https://github.com/keopx/docker-varnish/blob/master/4.0/Dockerfile))

### Apache PHP
- 7.2, latest ([7.2/Dockerfile](https://github.com/keopx/docker-apache-php/blob/master/7.2/Dockerfile))
- 7.1 ([7.1/Dockerfile](https://github.com/keopx/docker-apache-php/blob/master/7.1/Dockerfile))
- 7.0 ([7.0/Dockerfile](https://github.com/keopx/docker-apache-php/blob/master/7.0/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-apache-php/blob/master/5.6/Dockerfile))

### MySQL
- 8.0, latest ([8.0/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/8.0/Dockerfile))
- 5.7 ([5.7/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/5.7/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/5.6/Dockerfile))
- 5.5 ([5.5/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/5.6/Dockerfile))

### Redis
- 3.2, latest ([3.2/Dockerfile](https://github.com/keopx/docker-redis/blob/master/3.2/Dockerfile))
- 3.0 ([3.0/Dockerfile](https://github.com/keopx/docker-redis/blob/master/3.0/Dockerfile))

### phpMyAdmin

This is a default image. Only use to have a easy access to database information.

### MailHog

This is a default image. Use to have easy mailsender and mail watcher to test email without send to real account.

## Custom settings

### Varnish

By default we can use a standard _default.vcl_.

In addition, you can check a varnish vcl for [Drupal](https://www.drupal.org) in [drupal-base.vcl](https://github.com/keopx/docker-lamp/blob/master/config/varnish/drupal-base.vcl)

#### drupal-base.vcl for Drupal

You can check a special varnish vcl file for [Drupal](https://wwww.drupal.org) **drupal-base.vcl** based in [NITEMAN](https://github.com/NITEMAN) config file: [drupal-base.vcl](https://github.com/NITEMAN/varnish-bites/blob/master/varnish4/drupal-base.vcl)

**Note**: drupal-base.vcl uses MIT license.

If you like to add **drupal-base.vcl** add this lines. Added by default 
     
```yml
    volumes:
      - ./config/varnish/drupal-base.vcl:/etc/varnish/default.vcl
```

#### Environment

The first two lines works to setup a default varnish port and memory usage limit.

The second two lines only works to change **default.vcl** setup to run correctly.

_web_ is name of linked _apache-php_ image name.

```yml
    environment:
      - VARNISH_PORT=80
      - VARNISH_MEMORY=500M
      # Next values only works with default default.vcl file.
      - VARNISH_BACKEND_IP=web
      - VARNISH_BACKEND_PORT=80
```

### Apache PHP

#### Web Data Volume

```yml
    volumes:
      - ./data/www:/var/www # Data.
```

#### Apache Virtualhost

By default you can use http://localhost as working place. But if you would like a custom host to work add this changes.

You can see _volumes_ to check existing configurations for _vhosts_. _vhosts_ volume mount by default to help with setup.

```yml
    - ./config/vhosts:/etc/apache2/sites-enabled
```

**Note:** this example is for _www.drupal8.local_ site.

```bash
#!bash

cp config/vhosts/example.conf.example config/vhosts/drupal8.conf
sed -i 's/example/drupal8/' config/vhosts/drupal8.conf
```

_NOTE: review your project path._

Add to _/etc/hosts_ new site _name_:

```bash
echo "127.0.0.1 drupal8.local www.drupa8.local" >> /etc/hosts
```


And reload system:

```bash
$ docker-compose stop
$ docker-compose up -d
```

#### PHP

Use some setup by default. You can (un)comment to change behaviour.

You can see **two _php.ini_ templates** with different setup, [development](https://github.com/keopx/docker-lamp/blob/master/config/php/php.ini-development) and [production](https://github.com/keopx/docker-lamp/blob/master/config/php/php.ini-production) setup.

In addition, you can check **apcu**, **opcache**, **xdebug** and **xhprof** configuration, the same file for php 7.1, 7.0 and 5.6, and  **opcache** recomended file version for [Drupal](https://wwww.drupal.org).

##### PHP 5.6

```yml
      # php.ini for php 5.6 and remove environment varibles.
      - ./config/php/5.6/php.ini:/etc/php/5.6/apache2/php.ini
      # Opcache for php 5.6
      - ./config/php/opcache-recommended.ini:/etc/php/5.6/apache2/conf.d/05-opcache.ini
      # APCU for php 5.6
      - ./config/php/apcu.ini:/etc/php/5.6/apache2/conf.d/20-apcu.ini
      # Xdebug for php 5.6.
      - ./config/php/xdebug.ini:/etc/php/5.6/apache2/conf.d/20-xdebug.ini
      # Xhprof for php 5.6.
      - ./config/php/xhprof.ini:/etc/php/5.6/apache2/conf.d/20-xhprof.ini
```

##### PHP >= 7.0

This example is for PHP 7.0. If you would like use PHP 7.1/7.2 change the next lines from 7.0 to 7.1/7.2.

```yml
      # php.ini for php 7.x and remove environment varibles.
      - ./config/php/7.0/php.ini:/etc/php/7.0/apache2/php.ini
      # Opcache for php 7.0.
      - ./config/php/opcache-recommended.ini:/etc/php/7.0/apache2/conf.d/10-opcache.ini
      # APC for php 7.0. Necessary to works APCu in PHP 7.0.
      - ./config/php/apc.ini:/etc/php/7.0/apache2/conf.d/20-apc.ini
      # APCU for php 7.0
      - ./config/php/apcu.ini:/etc/php/7.0/apache2/conf.d/20-apcu.ini
      # Xdebug for php 7.0.
      - ./config/php/xdebug.ini:/etc/php/7.0/apache2/conf.d/20-xdebug.ini
      # Xhprof for php 7.0.
      - ./config/php/xhprof.ini:/etc/php/7.0/apache2/conf.d/20-xhprof.ini
```

_NOTE: if you like enabled APCu in PHP 7.0, you need enabled apc.ini._

e.g.: if you need add more PHP memory_limit modify _./config/php-{version}/php.ini_ file and reload system to works:

```bash
$ docker-compose stop
$ docker-compose up -d
```

#### Xdebug

Xdebug is enabled to debug shell command as drush.

Can read this post [https://www.keopx.net/blog/debugging-drush-scripts-con-xdebug-y-phpstorm](https://www.keopx.net/blog/debugging-drush-scripts-con-xdebug-y-phpstorm)

_Note: remember check docker-compose.yml to enable this feature._ 

#### Drush

If you need run some drush command to sync with some alias, to access to remote sync database or files you can uncomment next line to works into docker image.

```yml
      # Drush support. e.g.
      - ~/.drush:/root/.drush
```

#### SSH

If you need run some command, like a composer, to access to remote using ssh keys, you can uncomment next line to works into docker image. 

```yml
      # SSH support. e.g.
      - ~/.ssh:/root/.ssh
```

#### Environment

**WARNING**: Use only if you not use custom php.ini.

You can check in docker-composer.yml two special environment variable to setup SMTP service to test local emails.

The _apache-php_ has _ssmtp_ sender package. Here default setup to run by default with mailhog.

Use to connect to MailHog **mail** instead *localhost*.

```yml
    environment:
      # ssmtp mail sender.
      - PHP_SENDMAIL_PATH="/usr/sbin/ssmtp -t"
      # SMTP server configruation: "domain:port" | "mail" server domain is mailhog name.
      - PHP_SENDMAIL_DOMAIN=mail:1025
```

### MySQL

Use to connect to MySQl **mysql** instead *localhost*.

#### MySQL Data Volume

```yml
    volumes:
      - ./data/database:/var/lib/mysql
```
#### Custom my.cnf

You can check [my.cnf](https://github.com/keopx/docker-lamp/blob/master/config/mysql/my.cnf) and change you need variables.

```yml
      ## Custom setup for MySQL
      - ./config/mysql/my.cnf:/etc/mysql/my.cnf
```

#### Environment

* MYSQL_ROOT_PASSWORD: The password for the root user. Defaults to a blank password.
* MYSQL_DATABASE: A database to automatically create. If not provided, does not create a database.
* MYSQL_USER: A user to create that has access to the database specified by MYSQL_DATABASE.
* MYSQL_PASSWORD: The password for MYSQL_USER. Defaults to a blank password.

```yml
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=drupal
      - MYSQL_USER=drupaluser
      - MYSQL_PASSWORD=drupalpass
```

### Redis

Use Redis for backend cache system for Drupal.

Use to connect to Redis **redis** instead *localhost* and port *6379*.

### phpMyAdmin

Use to connect to MySQl **mysql** instead *localhost*.

#### Environment

* PMA_HOST: Host to connect phpMyAdmin.

```yml
    environment:
      - PMA_HOST=mysql
```

### MailHog

Default image and setup.
