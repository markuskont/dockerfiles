# build stage
FROM node:alpine as build-stage
WORKDIR /app
RUN apk add git
RUN git clone https://github.com/alerta/alerta-webui.git alerta
WORKDIR /app/alerta
RUN npm install
RUN npm run build

FROM nginx:stable-alpine
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN mkdir /var/www
COPY --from=build-stage /app/alerta/dist /var/www
COPY config.json /var/www/config.json
COPY nginx.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
