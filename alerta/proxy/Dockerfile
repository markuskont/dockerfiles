FROM nginx:alpine
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN apk --update add git \
&& git clone https://github.com/alerta/angular-alerta-webui.git /tmp/alerta \
&& mv /tmp/alerta/app /var/www \
&& rm -r /tmp/alerta

COPY config.js /var/www/config.js
COPY nginx.conf /etc/nginx/conf.d/default.conf
