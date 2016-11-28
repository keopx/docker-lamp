# Native docker-based local environment for Drupal

Use this Docker compose file to spin up local environment for [Drupal](https://wwww.drupal.org) with a *native Docker app*

This docker setup works with **Debian 8**, **Apache 2.4**, **MySQL 5.7/5.6/5.5/** and **PHP 7.0/5.6**.

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
        * [SSH](#ssh)
        * [Environment](#environment-1)
    * [MySQL](#mysql-1)
        * [MySQL Data Volume](#mysql-data-volume)
        * [Custom my.cnf](#custom-mycnf)
        * [Environment](#environment-2)
    * [phpMyAdmin](#phpmyadmin-1)
        * [Environment](#environment-3)
    * [Mailhog](#mailhog-1)

## Overview

The [Drupal](https://wwww.drupal.org) bundle consist of the following containers:

| Container | Version | Service name | Image | Public Port | Enabled by default |
| --------- | ------- | ------------ | ----- | ----------- | ------------------ |
| [Varnish](#varnish) | [4.0](https://github.com/keopx/docker-varnish/blob/master/4.0/) | varnish | <a href="https://hub.docker.com/r/keopx/varnish/" target="_blank">keopx/varnish</a> | 80 | ✓ |
| [Apache PHP](#apache-php) | [7.0](https://github.com/keopx/docker-apache2-php/blob/master/7.0/)/[5.6](https://github.com/keopx/docker-apache2-php/tree/master/5.6/) | apache2-php | <a href="https://hub.docker.com/r/keopx/apache2-php/" target="_blank">keopx/apache2-php</a> | 8008 | ✓ |
| [MySQL](#mysql) | [5.7](https://github.com/keopx/docker-mysql/blob/master/5.7/)/[5.6](https://github.com/keopx/docker-mysql/blob/master/5.6/)/[5.5](https://github.com/keopx/docker-mysql/blob/master/5.5/) | mysql | <a href="https://hub.docker.com/r/keopx/mysql/" target="_blank">keopx/mysql</a> | 3306 | ✓ |
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

- 4.0, latest ([4.0/Dockerfile](https://github.com/keopx/docker-varnish/blob/master/4.0/Dockerfile))

### Apache PHP
- 7.0, latest ([7.0/Dockerfile](https://github.com/keopx/docker-apache2-php/blob/master/7.0/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-apache2-php/tree/master/5.6/Dockerfile))

### MySQL
- 5.7, latest ([5.7/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/5.7/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-mysql/tree/master/5.6/Dockerfile))
- 5.5 ([5.5/Dockerfile](https://github.com/keopx/docker-mysql/tree/master/5.6/Dockerfile))

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

_web_ is name of linked _apache2-php_ image name.

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
$ docker-compose down
$ docker-compose up -d
```

#### PHP

Use some setup by default. You can (un)comment to change behaviour.

You can see **two _php.ini_ templates** with different setup, [development](https://github.com/keopx/docker-lamp/blob/master/config/php/php.ini-development) and [production](https://github.com/keopx/docker-lamp/blob/master/config/php/php.ini-production) setup.

In addition, you can check **xdebug** configuration, the same file for php 7.0 and 5.6, and  **opcache** recomended file version for [Drupal](https://wwww.drupal.org).

```yml
      - ./config/php/php.ini:/etc/php5/apache2/php.ini
      # Xdebug for php 5.6
      - ./config/php/xdebug.ini:/etc/php5/apache2/conf.d/20-xdebug.ini
      # Xdebug for php 7.0
      - ./config/php/xdebug.ini:/etc/php/7.0/apache2/conf.d/20-xdebug.ini
      # OpCache only for php 7.0
      - ./config/php/opcache-recommended.ini:/etc/php/7.0/apache2/conf.d/10-opcache.ini
```

e.g.: if you need add more PHP memory modify _./config/php/php.ini_ file and reload system to works:

```bash
$ docker-compose down
$ docker-compose up -d
```

#### SSH

If you need run some command, like a composer, to access to remote using ssh keys, you can uncomment next line to works into docker image. 

```yml
      # SSH support. e.g.
      - ~/.ssh:/root/.ssh
```

#### Environment

You can check in docker-composer.yml two special environment variable to setup SMTP service to test local emails.

The _apache2-php_ has _ssmtp_ sender package. Here default setup to run by default with mailhog.

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
