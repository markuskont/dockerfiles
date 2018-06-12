# Alerta

See:
  * http://alerta.io/
  * https://github.com/alerta/alerta

This docker environment will build a functional alerta dashboard on three images - mongodb backend database, flask api served via uwsgi, and nginx proxy server for angular frontend and `/api` endpoint. All communication between proxy and api components is done through unix socket in `/tmp/alerta`, thus this directory must be shared through docker volume.

## Getting started

Docker compose should package everything that's needed. Including shared volume creation. Proxy will be created on port `8080` and alerta flask api can be accessed via `<IP>:8080/api`.

```
docker-compose build && docker-compose up
```

You can build and run containers manually if you want, but [see shared volume creation first](https://docs.docker.com/engine/reference/commandline/volume_create/)

## HTTPS

Images are for internal usage, so this is not handled by dockerfiles. Users should customize [nginx config](proxy/nginx.conf) on proxy should htis be a requirement.
