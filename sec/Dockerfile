FROM perl:5.30 as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV version=2.8.2

RUN mkdir /app 
WORKDIR /app
RUN wget https://github.com/simple-evcorr/sec/releases/download/${version}/sec-${version}.tar.gz \
&& tar -xzf sec-${version}.tar.gz 

FROM perl:5.30

ENV version=2.8.2
ENV user=sec
ENV gid=61000
ENV working_dir=/var/lib/sec

COPY --from=Builder /app/sec-${version}/sec /usr/local/bin 
RUN ["cpanm", "JSON"] 

RUN groupadd -g $gid $user
RUN useradd -g $gid -l -M -s /bin/false -u $gid $user
RUN mkdir $working_dir && chown $user:$group $working_dir
USER $user
WORKDIR $working_dir

ENTRYPOINT ["/usr/local/bin/sec"]
