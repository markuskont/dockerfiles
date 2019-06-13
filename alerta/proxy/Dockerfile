FROM nginx:alpine
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN apk --update add git \
&& git clone https://github.com/alerta/angular-alerta-webui.git /tmp/alerta \
&& cd /tmp/alerta && git checkout tags/v6.8.5 \
&& mv /tmp/alerta/app /var/www \
&& rm -r /tmp/alerta

COPY config.json /var/www/config.json
COPY nginx.conf /etc/nginx/conf.d/default.conf
