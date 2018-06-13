FROM ubuntu:xenial

ENV INSTALL_PATH /src
#ENV SURICATA suricata-4.0.4
ENV SURICATA 325f336f637f8a3f4f2fb00c6cd6d0f04d5ca62f
ENV LIBHTP  0.5.26

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
&& apt-get -y autoremove && apt-get -y autoclean && apt-get clean

# execute unknown script from web as root, what could possibly go wrong
#RUN curl -sSf https://static.rust-lang.org/rustup.sh | sh

RUN apt-get update \
&& apt-get -qq -y install \
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
#libhyperscan-dev \
libhiredis-dev \
libluajit-5.1-dev \
liblz4-dev \
&& apt-get -y autoremove && apt-get -y autoclean && apt-get clean

RUN git clone https://github.com/OISF/suricata \
&& cd suricata \
#&& git checkout tags/$SURICATA \
&& git checkout $SURICATA . \
&& git clone https://github.com/OISF/libhtp.git \
&& cd libhtp \
&& git checkout tags/$LIBHTP && cd .. \
&& ./autogen.sh \
&& ./configure \
--prefix=/opt/suricata \
--sysconfdir=/etc \
--enable-hiredis \
--enable-profiling \
--enable-luajit \
--enable-python \
--enable-rust \
--enable-rust-experimental \
&& make && make install-full \
&& cd ../ && rm -r suricata

ENTRYPOINT ["/opt/suricata/bin/suricata"]
#CMD cd /src/suricata && checkinstall --install=no --pakdir=/srv -y --pkgversion=$SURICATA
# docker run --rm -ti -v $PWD:/srv markuskont/suricata
