FROM python:3.7
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV PYTHONUNBUFFERED 1

ARG DATABASE_URL="mongodb://mongo0:27017/monitoring"

RUN useradd -ms /bin/bash alerta && usermod -u 1000 alerta
RUN pip install alerta-server uwsgi

VOLUME /var/alerta/run
RUN chown alerta /var/alerta/run

COPY wsgi.py /var/alerta/wsgi.py
COPY uwsgi.ini /etc/uwsgi.ini
COPY alertad.conf /etc/alertad.conf
RUN chown alerta /etc/alertad.conf

CMD chown -R alerta /var/alerta/ && uwsgi --ini /etc/uwsgi.ini
