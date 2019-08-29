# build stage
FROM node:alpine as build-stage
WORKDIR /app
RUN apk add wget git
RUN wget https://github.com/alerta/alerta-webui/releases/latest/download/alerta-webui.tar.gz
RUN tar zxvf alerta-webui.tar.gz

FROM nginx:stable-alpine
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN mkdir /var/www
COPY --from=build-stage /app/dist /var/www
COPY config.json /var/www/config.json
COPY nginx.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
