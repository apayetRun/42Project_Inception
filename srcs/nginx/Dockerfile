FROM debian:buster

RUN apt update
RUN echo yes | apt upgrade

RUN echo yes | apt install nginx openssl

RUN mkdir /etc/nginx/ssl

RUN openssl req -newkey rsa:4096 -x509 -nodes -days 365 -subj "/C=FR/ST=France/L=Paris/O=42 Paris/OU=Student/CN=apayet.42.fr/emailAddress=apayet@student.42.fr" -keyout /etc/nginx/ssl/apayet.42.fr.key -out /etc/nginx/ssl/apayet.42.fr.cert
RUN rm /etc/nginx/sites-enabled/default


COPY ./server_block/apayet.42.fr.conf /etc/nginx/sites-available/
RUN	ln -s /etc/nginx/sites-available/apayet.42.fr.conf /etc/nginx/sites-enabled/

RUN rm -rf /var/www/html/index.nginx-debian.html

CMD ["nginx", "-g daemon off;"]

VOLUME [ "/var/www/html" ]

