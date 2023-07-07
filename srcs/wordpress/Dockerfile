# syntax=docker.io/docker/dockerfile:1
FROM debian:buster

RUN apt update
RUN echo yes | apt upgrade

RUN export DEBIAN_FRONTEND=noninteractive && echo yes | apt install php7.3 php-fpm php-mysql curl


RUN rm /etc/php/7.3/fpm/pool.d/www.conf
COPY ./conf/www.conf /etc/php/7.3/fpm/pool.d/
RUN mkdir -p /var/run/php
COPY ./conf/php-fpm.conf /etc/php/7.3/fpm/
RUN mkdir -p /var/www/html
RUN curl -o wordpress.tar.gz https://fr.wordpress.org/wordpress-6.1.1-fr_FR.tar.gz
RUN tar -xvf ./wordpress.tar.gz -C /var/www/html
RUN mv  /var/www/html/wordpress/* /var/www/html
RUN rm ./wordpress.tar.gz
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_DATABASE
RUN echo " \
<?php\n \
define( 'DB_NAME', '$MYSQL_DATABASE' );\n \
define( 'DB_USER', '$MYSQL_USER' );\n \
define( 'DB_PASSWORD', '$MYSQL_PASSWORD' );\n \
define( 'DB_HOST', 'mariadb:3306' );\n \
define( 'DB_CHARSET', 'utf8' );\n \
\n \
define( 'DB_COLLATE', '' );\n \
\$table_prefix = 'wp_';\n \
\n \
define( 'WP_DEBUG', true );\n \
\n \
/* C’est tout, ne touchez pas à ce qui suit ! Bonne publication. */\n \
\n \
/** Chemin absolu vers le dossier de WordPress. */\n \
if ( ! defined( 'ABSPATH' ) )\n \
  define( 'ABSPATH', dirname( __FILE__ ) . '/' );\n \
\n \
/** Réglage des variables de WordPress et de ses fichiers inclus. */\n \
require_once( ABSPATH . 'wp-settings.php' ); \n" > /var/www/html/wp-config.php

RUN touch /var/log/fpm-php.www.log && chmod 666 /var/log/fpm-php.www.log
RUN chmod -R 777 /var/www/html
VOLUME [ "/var/www/html" ]
