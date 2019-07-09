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

SEC process `GID` is `61000`. Make sure permissions are configured correctly if reading and writing from named pipes.

```
mkfifo /tmp/in.fifo
mkfifo /tmp/out.fifo
chgrp 61000 /tmp/*.fifo
chmod g+w /tmp/*.fifo
```

`/var/lib/sec/pipes` has been created for housing any FIFO files, but any path can be chosen. Simply make sure that paths are consistent between docker voluma mappings, SEC arguments, and configured outputs in rules.

```
docker run --rm -ti --name my-sec \
  -v $(pwd)/rules:/rules:ro \
  -v /tmp/in.fifo:/var/lib/sec/pipes/in.fifo:rw \
  -v /tmp/out.fifo:/var/lib/sec/pipes/out.fifo:rw \
  markuskont/sec \
    --conf="/rules/*.sec" \
		--input="/var/lib/sec/pipes/in.fifo" \
    --rwfifo
```

`/var/lib/sec/contexts` has been created to storing SEC internal cotext dumps, to maintain varibles between process restarts. This folder has also been exposed as docker volume and can therefore be accessed from other containers. For example, for running backups.

```
sudo docker run -rm --volumes-from my-sec -v $(pwd):/backup busybox tar cvf /backup/backup.tar /var/lib/sec/contexts
```

Note that automatically created volumes will be removed if `--rm` flag is used with `docker run`, or if container is removed via `docker rm <sec-container>`. A mapped volume should be explicitly created for more permanent persistence.

```
docker volume create sec-ctx
```
```
docker run --rm -ti --name my-sec \
  -v $(pwd)/rules:/rules:ro \
  -v sec-ctx:/var/lib/sec/contexts:rw \
  markuskont/sec \
    --conf="/rules/*.sec" \
```

See [frankensec repo](https://github.com/ccdcoe/frankenSEC/blob/master/rules/persist.sec) for example presistence rule. Also, avoid mounting folders from host filesystem as folder containing context dumps needs to be writeable to sec process. `docker volume` sidesteps issues with out of sync `UID` and `GID` values between host and containers.
