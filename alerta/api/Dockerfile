FROM python:3
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV PYTHONUNBUFFERED 1

ARG appdir="/app"
ARG DATABASE_URL="mongodb://mongo0:27017/monitoring"

ENV appdir ${appdir}
ENV UID 1050
ENV GID 1050
ENV DATABASE_URL $DATABASE_URL
ENV ALERTA_SRV_CONF_FILE "${appdir}/alertad.conf"

#RUN apk --update add postgresql-dev gcc
RUN pip install alerta-server uwsgi && mkdir ${appdir}
WORKDIR ${appdir}

COPY wsgi.py ${appdir}/wsgi.py
COPY uwsgi.ini ${appdir}/uwsgi.ini
COPY alertad.conf ${ALERTA_SRV_CONF_FILE}

RUN addgroup -gid ${GID} alerta && adduser -uid ${UID} -gid ${GID} --shell /bin/sh --disabled-login alerta
#USER alerta

VOLUME /tmp/alerta/
CMD chown ${GID}:${UID} /tmp/alerta && uwsgi --ini ${appdir}/uwsgi.ini
