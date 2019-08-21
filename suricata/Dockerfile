FROM ubuntu:bionic
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_PATH /src
ENV LIBHTP  0.5.30
ENV HYPERSCAN 5.1.1

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

RUN apt-get update \
&& apt-get install -qq -y \
git \
build-essential \
autogen \
autoconf \
libtool \
pkg-config \
python \
curl \
sudo \
rustc \
cargo \
cmake \
ragel \
&& apt-get -y autoremove && apt-get -y autoclean && apt-get clean

RUN apt-get update \
&& apt-get -qq -y install \
libboost-all-dev \
libpcre3 \
libpcre3-dbg \
libpcre3-dev \
libpcap-dev \
libnet1-dev \
libyaml-0-2 \
libyaml-dev \
zlib1g \
zlib1g-dev \
libcap-ng-dev \
libcap-ng0 \
libmagic-dev \
libjansson-dev \
libhiredis-dev \
libluajit-5.1-dev \
liblz4-dev \
libnss3-dev \
libnspr4-dev \
liblzma-dev \
&& apt-get -y autoremove && apt-get -y autoclean && apt-get clean

RUN git clone https://github.com/intel/hyperscan \
&& cd hyperscan \
&& git checkout tags/v$HYPERSCAN . \
&& cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_STATIC_AND_SHARED=1 && make -j 16 && make install && cd ../ && rm -r hyperscan

RUN git clone https://github.com/markuskont/suricata \
&& cd suricata \
&& git checkout custom/dockerize \
&& git clone https://github.com/OISF/libhtp.git \
&& cd libhtp \
&& git checkout tags/$LIBHTP && cd .. \
&& ./autogen.sh \
&& ./configure \
--prefix=/opt/suricata \
--sysconfdir=/etc \
--localstatedir=/var \
--enable-hiredis \
--enable-profiling \
--enable-luajit \
--enable-python \
--enable-rust \
--enable-rust-experimental \
&& make -j 16 && make install-full \
&& cd ../ && rm -r suricata && mkdir -p /var/log/suricata

ENV PATH "$PATH:/opt/suricata/bin"
ENTRYPOINT ["/opt/suricata/bin/suricata"]
