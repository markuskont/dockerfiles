FROM nginx:stable-alpine
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN mkdir /var/www
COPY nginx.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
