FROM ubuntu:jammy

ENV ARKIME_DIR /opt/arkime
ENV ARKIME_USER arkime

USER root
RUN apt-get update && apt-get -y install \
  libsocket6-perl \
  libtest-differences-perl \
  libwww-perl \
  libjson-perl \
  openssl \
  xz-utils \
  wget \
  curl \
  libyaml-0-2 \
  libmagic1 \
  ethtool \
  && apt-get -y autoremove && apt-get autoclean && apt-get clean

RUN wget -O /root/arkime.deb https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-22.04/arkime_4.2.0-1_amd64.deb
#RUN wget -O /root/arkime.deb https://s3.amazonaws.com/files.molo.ch/arkime-main_ubuntu20_amd64.deb
RUN dpkg -i /root/arkime.deb || apt-get install -f -y

ENV PATH "$PATH:$ARKIME_DIR/bin"

COPY entrypoint.sh  $ARKIME_DIR/bin/entrypoint.sh

WORKDIR $ARKIME_DIR
RUN useradd -ms /bin/bash $ARKIME_USER && \
  usermod -d $ARKIME_DIR -u 1000 $ARKIME_USER && \
  chown -R $ARKIME_USER $ARKIME_DIR

RUN mkdir $ARKIME_DIR/raw && chown $ARKIME_USER $ARKIME_DIR/raw

RUN $ARKIME_DIR/bin/arkime_update_geo.sh

ENTRYPOINT ["entrypoint.sh"]
