# Suricata

See:
  * http://suricata.readthedocs.io/en/latest/install.html#source
  * https://github.com/ccdcoe/CDMCS/tree/master/Suricata

Build Suricata with cool features like hyperscan, rust parsers, etc. Suricata is very complex piece of software with huge featureset and large list of dependencies. Thus, expect the image to be quite large. Hyperscan is built along with the image, as opposed to installing from binary or resorting to whatever version happens to be in repos (missing from xenial), so go for a coffee while building. It will take time.

## Gettings started

```
docker build -t markuskont/suricata .
```

Suricata binary is already defined as entrypoint. Thus, suricata cli flags can be invoked directly as container args.

```
docker run --rm -ti markuskont/suricata -V
```

Online `af-packet` capture works if in conjuction with `--network host` and `--privileged` flag. Former gives direct access to host interfaces while the latter avoids ioctl permission errors.

```
docker run --rm -ti --name meerkat --network host -v docker-volumes:/var/log/suricata:rw --privileged markuskont/suricata -c /etc/suricata/suricata.yaml --af-packet=enp37s0
```

Insecure as hell, but I only care about containing the dependencies. IDS world is already about as privileged as it gets.
