# Introduction #

This image works with **Debian 8**, **Apache 2.4**, **MySQL 5.7/5.6/5.5/** and **PHP 7.0/5.6**.

This is the [keopx](https://www.keopx.net) Docker **Drupal** optimized images for apache-php with varnish and MySQL.



## Varnish ##

Available tags are:

- 4.0, latest ([4.0/Dockerfile](https://github.com/keopx/docker-varnish/blob/master/4.0/Dockerfile))

### drupal-base.vcl ###

**drupal-base.vcl** based in [NITEMAN](https://github.com/NITEMAN) config file: [drupal-base.vcl](https://github.com/NITEMAN/varnish-bites/blob/master/varnish4/drupal-base.vcl)

**Note**: drupal-base.vcl uses MIT license.

## PHP ##
- 7.0, latest ([7.0/Dockerfile](https://github.com/keopx/docker-apache2-php/blob/master/7.0/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-apache2-php/tree/master/5.6/Dockerfile))

## MySQL ##
- 5.7, latest ([5.7/Dockerfile](https://github.com/keopx/docker-mysql/blob/master/5.7/Dockerfile))
- 5.6 ([5.6/Dockerfile](https://github.com/keopx/docker-mysql/tree/master/5.6/Dockerfile))
- 5.5 ([5.5/Dockerfile](https://github.com/keopx/docker-mysql/tree/master/5.6/Dockerfile))

## Usage ##

`$ docker-compose build`

`$ docker-compose up -d`

### Run bash ###

`docker exec -it dockerlamp_web_1 /bin/bash`

Replace _dockerlamp_web_1_ with _name_ of: 

`docker-compose ps`

## Other settings ##

### APACHE Virtualhost ###

By default you can use http://localhost as working place. But if you would like a custom host to work add this changes.

**Note:** this example is for _www.drupal8.local_ site.

```
#!bash

cp config/vhosts/example.conf.example config/vhosts/drupal8.conf
sed -i 's/example/drupal8/' config/vhosts/drupal8.conf
```

_NOTE: review your project path._

Add to _/etc/hosts_ new site _name_:

`echo "127.0.0.1 drupal8.local www.drupa8.local" >> /etc/hosts`

And reload system:

`$ docker-compose down`

`$ docker-compose up -d`


### PHP7 ###

Modify php.ini in *config/php*.

And reload system:

`$ docker-compose down`

`$ docker-compose up -d`


### MySQL ###

Use to connect to MySQl **mysql** instead *localhost*

* MYSQL_ROOT_PASSWORD: The password for the root user. Defaults to a blank password
* MYSQL_DATABASE: A database to automatically create. If not provided, does not create a database.
* MYSQL_USER: A user to create that has access to the database specified by MYSQL_DATABASE.
* MYSQL_PASSWORD: The password for MYSQL_USER. Defaults to a blank password.
