# build stage
FROM golang AS Builder

RUN mkdir -p /go/src/github.com/influxdata/
RUN git clone https://github.com/markuskont/telegraf /go/src/github.com/influxdata/telegraf/ -b custom/dockerize
WORKDIR  /go/src/github.com/influxdata/telegraf

RUN go get -u github.com/golang/dep/cmd/dep
RUN go install github.com/golang/dep/cmd/dep

RUN dep ensure
RUN CGO_ENABLED=0 go install github.com/influxdata/telegraf/cmd/...

# final stage
FROM alpine
COPY --from=Builder /go/bin/telegraf /usr/bin/telegraf

ENTRYPOINT ["/usr/bin/telegraf"]
