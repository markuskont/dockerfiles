FROM markuskont/moloch
LABEL maintainer="Markus Kont <alias013@gmail.com>"

RUN apt-get update && apt-get install -y ethtool && apt-get -y autoremove && apt-get autoclean && apt-get clean
ENV MOLOCH_ENV "CAPTURE"

WORKDIR /data/moloch
