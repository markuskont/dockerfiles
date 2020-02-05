FROM ubuntu:bionic as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN apt-get update
RUN apt-get install -y python-pip dbconfig-common sqlite3 python-virtualenv git npm
RUN git clone https://github.com/StamusNetworks/scirius /opt/scirius
RUN mkdir /wheels
WORKDIR /wheels
RUN pip wheel -r /opt/scirius/requirements.txt 
RUN pip wheel pyinotify gitdb gunicorn python-daemon
WORKDIR /opt/scirius
RUN pip install -r requirements.txt && pip install pyinotify gitdb gunicorn python-daemon
RUN npm install -g npm@latest webpack@3.11
RUN npm install
WORKDIR /opt/scirius/hunt
RUN npm install
RUN npm run build
RUN mkdir -p /var/log/scirius
WORKDIR /opt/scirius
RUN python manage.py migrate
RUN webpack
RUN python manage.py collectstatic

FROM ubuntu:bionic

COPY --from=Builder /wheels /wheels
COPY --from=Builder /opt/scirius /opt/scirius
WORKDIR /opt/scirius
RUN apt-get update && apt-get install -y python-pip sqlite3 git && apt-get -y autoremove && apt-get autoclean && apt-get clean && pip install -r requirements.txt -U -f /wheels && pip install pyinotify gitdb gunicorn python-daemon -U -f /wheels && rm -rf /wheels && rm -rf /root/.cache/pip
RUN mkdir -p /var/log/scirius && mkdir /var/run/scirius
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('vagrant', 'vagrant@localhost', 'vagrant')" | python manage.py shell
COPY entrypoint.sh /bin/entrypoint.sh
COPY local_settings.py /opt/scirius/scirius/local_settings.py
RUN chmod 755 /bin/entrypoint.sh

ENV user=scirius
ENV uid=61000
ENV home=/opt/scirius
RUN useradd -ms /bin/false $user && usermod -d $home $user && chown -R $user $home/ && chown -R $user /var/log/scirius && chown -R $user /var/run/scirius
USER $user
WORKDIR $home
VOLUME [ "/opt/scirius/static" ]

ENTRYPOINT [ "/bin/entrypoint.sh" ]
