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
docker run --rm -ti -v $PWD:/srv markuskont/suricata -V
```
