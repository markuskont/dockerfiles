# Build stage
FROM python:3.7-alpine AS Builder

WORKDIR /tmp
RUN apk add wget
RUN wget https://raw.githubusercontent.com/ccdcoe/frankenSEC/master/sec2alerta/sec2alerta.py

WORKDIR /wheels
RUN pip wheel iso8601 requests

# final stage
FROM python:3.7-alpine

ENV user=worker
ENV gid=61000
ENV working_dir=/var/lib/worker

COPY --from=Builder /tmp/sec2alerta.py /usr/local/bin/

COPY --from=Builder /wheels /wheels 
RUN pip install -U iso8601 requests -f wheels && rm -rf /wheels && rm -rf /root/.cache/pip

RUN addgroup -S $gid && adduser --disabled-password -G $gid -H -s /bin/false -u $gid -h $working_dir $user
RUN mkdir -p $working_dir && chown -R $user:$gid $working_dir
VOLUME $working_dir
USER $user
WORKDIR $working_dir


ENTRYPOINT ["python", "/usr/local/bin/sec2alerta.py"]
