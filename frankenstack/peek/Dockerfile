# build stage
FROM golang AS Builder

RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN apt-get update && apt-get install -y gcc git
RUN mkdir -p /go/src/github.com/ccdcoe/
RUN git clone https://github.com/ccdcoe/go-peek /go/src/github.com/ccdcoe/go-peek
WORKDIR /go/src/github.com/ccdcoe/go-peek
RUN dep ensure
RUN go build -o /tmp/peek ./cmd/peek/...

# final stage
FROM alpine
COPY --from=Builder /tmp/peek /usr/local/bin/

ENV user=peek
ENV gid=61000
ENV working_dir=/var/lib/peek

RUN mkdir -p $working_dir && chown -R $user:$gid $working_dir
VOLUME $working_dir
USER $user
WORKDIR $working_dir

ENTRYPOINT ["/usr/local/bin/peek"]
