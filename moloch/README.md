# moloch

## Building images

Simple makefile is provided.

```
make build
```

Getting rid of containers.

```
make clean
```

## Parse offline pcap with WISE threat intel

Create a network for entire stack.

```
docker network create -d bridge moloch
```

Set up session persistence.

```
docker volume create moloch-elastic
```

Start up an elastic instance. Exposing port `9200` is not needed when only using through viewer.

```
docker run -itd \
	--name moloch-elastic \
	-h moloch-elastic \
	--network moloch \
	-e "ES_JAVA_OPTS=-Xms16g -Xmx16g" \
	-e "node.name=node-0" \
	-e "cluster.name=ludwig" \
	--restart unless-stopped \
	-v moloch-elastic-0:/usr/share/elasticsearch/data \
	-p 9200:9200 \
	docker.elastic.co/elasticsearch/elasticsearch-oss:6.7.1
```

Start up wise before capture. Entrypoint config is minimal. You need to pass your own `wise.ini` and place it in `etc` directory inside the container. Make sure that data sources are also mounted in the container, if loaded from files.

```
docker run -ti --rm \
  --name moloch-docker-wise \
  --network moloch \
  -v /home/user/Projects/ipmap.json:/tmp/ipmap.json:ro \
  -v /home/user/Projects/wise.ini:/data/moloch/etc/wise.ini:ro \
  markuskont/moloch-wise
```

Then run capture. `MOLOCH_WISE_HOST` should match wise container `--name` and `MOLOCH_ELASTICSEARCH` should match the same for elasticsearch. No need to initialize database by hand. Entrypoint will take care of it.

```
docker run -ti --rm \
  --name moloch-docker-capture \
  -h moloch-docker-capture \
  --network moloch \
  -e "MOLOCH_WISE_HOST=moloch-docker-wise" \
  -e "MOLOCH_ADMIN_USER=admin" \
  -e "MOLOCH_ELASTICSEARCH=moloch-elastic:9200" \
  -e "MOLOCH_PACKET_THREADS=16" \
  -e "MOLOCH_INCLUDES=/tmp/override.ini" \
  -v /srv/pcap/:/srv/pcap:ro \
  -v /home/user/Projects/override.ini:/tmp/override.ini:ro \
  markuskont/moloch-capture -R /srv/pcap --monitor --recursive
```

`-h` parameter is important for capture, as this will derive the moloch `node` field that must also match in viewer. Otherwise, pcap session load from disk will break, even if the host folder is correctly mounted for viewer image.

```
docker run -ti --rm \
  --name moloch-docker-viewer \
  --network moloch \
  -e "MOLOCH_WISE_HOST=moloch-docker-wise" \
  -e "MOLOCH_ADMIN_USER=admin" \
  -e "MOLOCH_ADMIN_PASS=stronk" \
  -e "MOLOCH_ELASTICSEARCH=moloch-elastic:9200" \
  -e "MOLOCH_INCLUDES=/tmp/override.ini" \
  -v /srv/pcap:/srv/pcap:ro \
  -v /home/user/Projects/override.ini:/tmp/override.ini:ro \
  -p 8005:8005 \
  markuskont/moloch-viewer --host moloch-docker-capture
```
