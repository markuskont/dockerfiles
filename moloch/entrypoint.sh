#!/bin/bash

CONFIG=/data/moloch/etc/config.ini
ifaces="enp0s3"
cp $CONFIG.sample $CONFIG

sed -i "s/MOLOCH_INSTALL_DIR/\/data\/moloch/g"    $CONFIG

if [[ -z "${MOLOCH_ELASTICSEARCH}" ]]; then
  MOLOCH_ELASTICSEARCH="localhost:9200"
fi
if [[ -z "${MOLOCH_INTERFACE}" ]]; then
  MOLOCH_INTERFACE="eth0"
fi
if [[ -z "${MOLOCH_PASSWORD}" ]]; then
  MOLOCH_PASSWORD="D0ker1z3dd#"
fi

sed -i "s/MOLOCH_ELASTICSEARCH/${MOLOCH_ELASTICSEARCH}/g" $CONFIG
sed -i "s/MOLOCH_INTERFACE/${MOLOCH_INTERFACE}/g"         $CONFIG
sed -i "s/MOLOCH_PASSWORD/${MOLOCH_PASSWORD}/g"           $CONFIG

case ${MOLOCH_ENV} in
  "CAPTURE" )
    MOLOCH_ELASTICSEARCH=$(echo ${MOLOCH_ELASTICSEARCH} | cut -d "," -f1)
    curl -ss $MOLOCH_ELASTICSEARCH || echo "unable to connect to elastic ${MOLOCH_ELASTICSEARCH}" ; exit 1
    if [[ `./db/db.pl ${MOLOCH_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      echo "INIT" | ./db/db.pl ${MOLOCH_ELASTICSEARCH} init
    fi
    moloch-capture -c $CONFIG --help
    ;;
  "VIEWER" )
    MOLOCH_ELASTICSEARCH=$(echo ${MOLOCH_ELASTICSEARCH} | cut -d "," -f1)
    curl -ss $MOLOCH_ELASTICSEARCH || echo "unable to connect to elastic ${MOLOCH_ELASTICSEARCH}" ; exit 1
    if [[ `./db/db.pl ${MOLOCH_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      echo "elastic connection to ${MOLOCH_ELASTICSEARCH} OK, but database is missing. Please create."
      exit 1
    fi
    ../bin/node viewer.js -c $CONFIG
    ;;
  *)
    echo "MOLOCH_ENV undefined"
esac
