# syntax=docker.io/docker/dockerfile:1
FROM debian:buster

RUN groupadd mysql
RUN useradd mysql -g mysql

# Update the system and install mariadb server
RUN apt update && apt upgrade -y 
RUN apt install -y mariadb-server

# Install the database configuration
RUN echo copy my.cnf
COPY ./my.cnf /etc/mysql/my.cnf
COPY ./etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Create the folder for the socket and give right for mysql_user
RUN mkdir /run/mysqld && chown mysql /run/mysqld

ARG MYSQL_ROOT_PASSWORD
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG MYSQL_DATABASE
ARG WP_ADMIN_USER
ARG WP_ADMIN_PASSWORD
ARG WP_ADMIN_EMAIL

ARG WP_REGULAR_USER
ARG WP_REGULAR_PASSWORD
ARG WP_REGULAR_EMAIL

# The dump of the database in first step with mysqldump
COPY ./data-dump.sql /tmp/data-dump.sql

RUN <<EOF mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
EOF

RUN service mysql start && mysql -u root $MYSQL_DATABASE < /tmp/data-dump.sql

RUN <<EOF mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap
USE $MYSQL_DATABASE;
insert into wp_users 
	(user_login,user_pass, user_nicename,user_email,user_url,user_registered,user_activation_key,user_status,display_name) 
	values ('$WP_ADMIN_USER','undefined password','$WP_ADMIN_USER','$WP_ADMIN_EMAIL','','2022-04-05 09:43','',0,'$WP_ADMIN_USER');
update wp_users set user_pass=MD5('$WP_ADMIN_PASSWORD') where id=1;

insert into wp_usermeta (user_id, meta_key, meta_value) values (1,'wp_capabilities','a:1:{s:13:"administrator";b:1;} ');
insert into wp_users 
	(user_login,user_pass, user_nicename,user_email,user_url,user_registered,user_activation_key,user_status,display_name) 
	values ('$WP_REGULAR_USER', MD5('$WP_REGULAR_PASSWORD'),'$WP_REGULAR_USER','$WP_REGULAR_EMAIL','','2022-04-05 09:43','',0,'$WP_REGULAR_USER');
EOF

RUN <<EOF mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER '$MYSQL_USER'@'wordpress.inception' IDENTIFIED BY '$MYSQL_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'wordpress.inception' IDENTIFIED BY '$MYSQL_PASSWORD';
SELECT user, host FROM mysql.user WHERE user='$MYSQL_USER';
FLUSH PRIVILEGES;
EOF

RUN rm -f /tmp/data-dump.sql

VOLUME /var/lib/mysql
