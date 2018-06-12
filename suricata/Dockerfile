FROM debian:stretch

RUN apt-get update && apt-get install -qq -y \
git \
build-essential \
autogen \
autoconf \
libtool \
pkg-config \
python \
checkinstall \
curl \
sudo

ENV INSTALL_PATH /src
ENV VERSION 4.1.0-beta1
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
RUN git clone https://github.com/OISF/suricata \
&& cd suricata \
&& git checkout tags/$VERSION

RUN cd suricata && git clone https://github.com/OISF/libhtp.git \
&& cd libhtp \
&& git checkout tags/0.5.25

RUN apt-get -y install \
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
libhyperscan-dev \
libhiredis-dev \
libluajit-5.1-dev

# execute unknown script from web as root, what could possibly go wrong
#RUN curl -sSf https://static.rust-lang.org/rustup.sh | sh

RUN cd suricata && ./autogen.sh
RUN cd suricata && ./configure \
--prefix=/opt/suricata \
--sysconfdir=/etc \
--enable-hiredis \
--enable-profiling \
--enable-luajit \
--enable-python \
--enable-rust \
--enable-rust-experimental

RUN cd suricata && make && make install-full

CMD cd /src/suricata && checkinstall --install=no --pakdir=/srv -y --pkgversion=$VERSION

# docker run --rm -ti -v $PWD:/srv markuskont/suricata
