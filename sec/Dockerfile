FROM perl:5.30 as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV version=2.8.2

RUN mkdir /app 
WORKDIR /app
RUN wget https://github.com/simple-evcorr/sec/releases/download/${version}/sec-${version}.tar.gz \
&& tar -xzf sec-${version}.tar.gz 

FROM perl:5.30

ENV version=2.8.2

COPY --from=Builder /app/sec-${version}/sec /usr/local/bin
ENTRYPOINT ["/usr/local/bin/sec"]
