FROM perl:5.24 as Builder
LABEL maintainer="Markus Kont <alias013@gmail.com>"

ENV version=2.8.2

RUN mkdir /app 
WORKDIR /app
RUN wget https://github.com/simple-evcorr/sec/releases/download/${version}/sec-${version}.tar.gz \
&& tar -xzf sec-${version}.tar.gz 

RUN ["cpanm", "JSON"]

FROM perl:5.24

ENV version=2.8.2
ENV user=sec
ENV gid=61000
ENV working_dir=/var/lib/sec
ENV log_dir=/var/log/sec

COPY --from=Builder /app/sec-${version}/sec /usr/local/bin
COPY --from=Builder /usr/local/lib/perl5/site_perl/5.24.4/JSON.pm /usr/share/perl5/

RUN groupadd -g $gid $user
RUN useradd -g $gid -l -M -s /bin/false -u $gid -d $working_dir $user
RUN mkdir -p $working_dir \
  && mkdir -p $working_dir/pipes \
  && mkdir -p $working_dir/contexts \
  && chown -R $user:$group $working_dir
RUN mkdir -p $log_dir && chown -R $user:$group $log_dir

VOLUME $working_dir/contexts

USER $user
WORKDIR $working_dir

ENTRYPOINT ["/usr/local/bin/sec"]
