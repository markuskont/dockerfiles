FROM ubuntu:bionic as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_PATH /src

RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN apt-get update && apt-get -y install sudo git python-minimal python-yaml libpcre3-dev libyaml-dev uuid-dev libmagic-dev pkg-config g++ flex bison zlib1g-dev libffi-dev gettext libgeoip-dev make libjson-perl libbz2-dev libwww-perl libpng-dev xz-utils libffi-dev libsnappy-dev build-essential

RUN git clone https://github.com/markuskont/moloch.git \
&& cd moloch \
&& ./easybutton-build.sh -d /data/moloch

RUN useradd -ms /bin/bash build && usermod -u 1000 build
RUN chown -R build /src
RUN chown -R build /data/moloch
USER build

ENV PATH "$PATH:/data/moloch/bin"

RUN cd moloch \
&& make install

WORKDIR /data/moloch/bin
RUN ./moloch_update_geo.sh
WORKDIR /data/moloch/wiseService

RUN ../bin/npm install bloomfilter
RUN ../bin/npm install hashtable

FROM ubuntu:bionic

USER root
RUN apt-get update && apt-get -y install wget curl libpcre3-dev uuid-dev libmagic-dev zlib1g-dev libffi-dev libgeoip-dev libjson-perl libbz2-dev libwww-perl libpng-dev xz-utils libffi-dev libssl-dev libreadline-dev libyaml-dev libsocket6-perl libtest-differences-perl && apt-get -y autoremove && apt-get autoclean && apt-get clean

ENV PATH "$PATH:/data/moloch/bin"
COPY --from=Builder /data /data
WORKDIR /data/moloch
RUN useradd -ms /bin/bash moloch && usermod -d /data/moloch -u 1000 moloch && chown -R moloch /data/moloch
RUN mkdir /data/moloch/raw && chown nobody /data/moloch/raw

COPY entrypoint.sh  /data/moloch/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
