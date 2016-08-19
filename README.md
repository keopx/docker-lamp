# Introduction #

This image works with **Debian 8**, **Apache 2.4**, **MySQL 5.5** and **PHP7**.

## Example usage: ##

`$ docker-compose build`

`$ docker-compose up -d`

## Run bash ##

`docker exec -it dockerlamp_web_1 /bin/bash`

Replace _dockerlamp_web_1_ with _name_ of: 

`docker-compose ps`

## APACHE Virtualhost##

By default you can use http://localhost as working place. But if you would like a custom host to work add this changes.

**Note:** this example is for _www.drupal8.local_ site.

```
#!bash

cp config/vhosts/example.conf.example config/vhosts/drupal8.conf
sed -i 's/example/drupal8/' config/vhosts/drupal8.conf
```

Add to _/etc/hosts_ new site _name_:

`echo "127.0.0.1 drupal8.local www.drupa8.local" >> /etc/hosts`

And reload system:

`$ docker-compose down`

`$ docker-compose up -d`

## Environment variables ##

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
