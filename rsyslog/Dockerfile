FROM debian:stretch
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN apt-get update && apt-get install -qq -y git build-essential autogen autoconf libtool pkg-config python-docutils flex bison libgrok1 librdkafka1 libestr-dev zlib1g-dev uuid-dev libsystemd-dev libgcrypt20-dev liblogging-stdlog-dev libcurl4-gnutls-dev librdkafka-dev libgrok-dev libpcre3-dev libtokyocabinet-dev libglib2.0-dev gnutls-dev libestr-dev && apt-get -y autoremove && apt-get -y autoclean && apt-get clean

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_PATH /src
ENV RSYSLOG v8.2010.0
ENV LIBFASTJSON v0.99.8
ENV LIBLOGNORM v2.0.6

RUN mkdir -p $INSTALL_PATH

RUN git clone https://github.com/rsyslog/libfastjson.git \
&& cd libfastjson \
&& git checkout tags/$LIBFASTJSON \
&& sh autogen.sh \
&& ./configure \
&& make \
&& make install \
&& cd .. && rm -r libfastjson

RUN git clone https://github.com/rsyslog/liblognorm.git \
&& cd liblognorm \
&& git checkout tags/$LIBLOGNORM \
&& autoreconf --install \
&& ./configure \
&& make \
&& make install \
&& cd .. && rm -r liblognorm

WORKDIR $INSTALL_PATH
RUN git clone https://github.com/rsyslog/rsyslog/ \
&& cd rsyslog \
&& git checkout tags/$RSYSLOG \
&& ./autogen.sh \
&& ./configure \
--enable-elasticsearch \
--enable-imkafka \
--enable-imjournal \
--enable-omkafka \
--enable-mmnormalize \
--enable-mmjsonparse \
--enable-mmgrok \
--enable-mmrm1stspace \
--enable-gnutls \
--enable-omuxsock \
--enable-mmanon \
--enable-mmfields \
&& mkdir -p /usr/lib/rsyslog \
&& make && make install \
&& echo /usr/lib/rsyslog > /etc/ld.so.conf.d/rsyslog.conf \
&& ldconfig \
&& cd ../ && rm -r rsyslog


RUN mkdir /var/run/rsyslog && mkdir /var/spool/rsyslog && mkdir /etc/rsyslog.d #&& rm -r /var/log/syslog*

COPY rsyslog.conf /etc/rsyslog.conf
COPY 001-default.conf /etc/rsyslog.d/001-default.conf

ENTRYPOINT ["rsyslogd", "-n"]
