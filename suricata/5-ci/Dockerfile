FROM debian:buster as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_PATH /src
ENV LIBHTP  0.5.33
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
python3 \
curl \
sudo \
cmake \
ragel

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
libhyperscan-dev \
libhyperscan5

RUN curl $CURL_OTPS --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s - -y
ENV PATH "/root/.cargo/bin:$PATH"
RUN cargo install --force cbindgen

RUN git clone https://github.com/oisf/suricata
WORKDIR /${INSTALL_PATH}/suricata/
RUN git checkout tags/suricata-5.0.3 \
&& git clone https://github.com/OISF/libhtp.git \
&& cd libhtp \
&& git checkout tags/$LIBHTP && cd ..
RUN ./autogen.sh 
RUN ./configure \
--prefix=/opt/suricata \
--sysconfdir=/etc \
--localstatedir=/var \
--enable-hiredis \
--enable-luajit \
--enable-python \
--enable-rust \
--enable-rust-experimental
RUN make -j 16 
RUN make install
RUN make install-conf

FROM debian:buster
USER root

RUN apt-get update \
&& apt-get -qq -y install \
libpcre3 \
libpcre3-dbg \
libyaml-0-2 \
zlib1g \
libcap-ng0 \
libhyperscan5 \
libhiredis0.14 \
libluajit-5.1-2 \
libmagic1 \
libpcap0.8 \
libnet1 \
libjansson4 \
libnss3 \
python3 \
&& apt-get -y autoremove && apt-get -y autoclean && apt-get clean

RUN mkdir /etc/suricata
RUN mkdir /var/log/suricata

COPY --from=Builder /opt/suricata /opt/suricata
COPY --from=Builder /etc/suricata /etc/suricata

ENV PATH "$PATH:/opt/suricata/bin"
CMD sh
#ENTRYPOINT ["/opt/suricata/bin/suricata"]
