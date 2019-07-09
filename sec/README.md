# SEC

This is a dockerized version of [Simple Event Correlator](https://simple-evcorr.github.io/). Mainly for use in [Frankenstack](https://github.com/ccdcoe/frankensec) project.

## Building

```
docker build -t markuskont/sec .
```

## Usage

This is simply a multi-stage docker image with `sec` perl script as entrypoint. Thus, the container can be invoked with any cli argument supported by SEC.

```
docker run --rm -ti markuskont/sec --help
```

Rules and input logs should be mounted as docker volumes to be accessible to the perl process.

```
docker run --rm -ti --name my-sec \
  -v $(pwd)/rules:/rules:ro \
  -v /var/log:/logs:ro \
	-v /dev/log:/dev/log:rw \
  markuskont/sec \
    --conf="/rules/*.sec" \
		--input="/logs/syslog" \
    --log=/var/log/sec/frankensec.log
```
