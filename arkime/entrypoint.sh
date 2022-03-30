#!/bin/bash

case ${ARKIME_ENV} in
  "WISE" )
    CONFIG=$ARKIME_DIR/etc/wise.ini
    if [[ ! -f $CONFIG ]]; then
      echo "creating wise config file"
      cp $CONFIG.sample $CONFIG
    fi
    ;;
  *)
    CONFIG=$ARKIME_DIR/etc/config.ini
    if [[ ! -f $CONFIG ]]; then
      cp $CONFIG.sample $CONFIG

      ARKIME_CAPTURE_PLUGINS="wise.so"
      if [[ ! -z ${ARKIME_SURICATA_FILE} ]]; then
        ARKIME_CAPTURE_PLUGINS+=";suricata.so"
      fi

      sed -i "s,dropUser=nobody,dropUser=arkime,g" $CONFIG
      sed -i "s,ARKIME_INSTALL_DIR,$ARKIME_DIR,g"  $CONFIG

      sed -i -e "s,# plugins=tagger.so; netflow.so,plugins=${ARKIME_CAPTURE_PLUGINS},g"                                         $CONFIG
      sed -i -e "s,# viewerPlugins=wise.js,viewerPlugins=wise.js\nwiseTcpTupleLookups=true\nwiseUdpTupleLookups=true\n,g"   $CONFIG

      if [[ -n ${ARKIME_SURICATA_FILE} ]]; then
        grep "suricataAlertFile" $CONFIG || sed -i -e "/plugins=${ARKIME_CAPTURE_PLUGINS}/asuricataAlertFile=${ARKIME_SURICATA_FILE}" $CONFIG
      fi
      if [[ -z ${ARKIME_WISE_PORT} ]]; then
        ARKIME_WISE_PORT=8081
      fi
      if [[ -z "${ARKIME_ELASTICSEARCH}" ]]; then
        ARKIME_ELASTICSEARCH="elasticsearch:9200"
      fi
      if [[ -z "${ARKIME_INTERFACE}" ]]; then
        ARKIME_INTERFACE="eth0"
      fi
      if [[ -z "${ARKIME_PASSWORD}" ]]; then
        ARKIME_PASSWORD="D0ker1z3dd#"
      fi
      if [[ -n "${ARKIME_WISE_HOST}" ]]; then
        sed -i -e "s,#wiseHost=127.0.0.1,wiseHost=${ARKIME_WISE_HOST}\nwisePort=${ARKIME_WISE_PORT}\n,g" $CONFIG
      fi
      if [[ -n "${ARKIME_PACKET_THREADS}" ]]; then
        sed -i -e "s/packetThreads=2/packetThreads=${ARKIME_PACKET_THREADS}/g" $CONFIG
      fi
      if [[ -n "${ARKIME_INCLUDES}" ]]; then
        sed -i -e "s,#includes=,includes=${ARKIME_INCLUDES},g" $CONFIG || exit 1
      fi
      if [[ -n "${ARKIME_READ_TRUNCATED}" ]]; then
        sed -i '/\[default\]/areadTruncatedPackets=true' $CONFIG
      fi
      if [[ -n "${ARKIME_MAX_SNAPLEN}" ]]; then
        sed -i '/\[default\]/asnapLen=65536' $CONFIG
      fi

      # this does not work with virbr
      # sed -i '/\[default\]/apcapReadMethod=tpacketv3'          $CONFIG
      sed -i "s|ARKIME_ELASTICSEARCH|${ARKIME_ELASTICSEARCH}|g" $CONFIG
      sed -i "s/ARKIME_PASSWORD/${ARKIME_PASSWORD}/g"           $CONFIG
      sed -i "s/ARKIME_INTERFACE/${ARKIME_INTERFACE}/g"         $CONFIG
    fi
    ;;
esac

if [ ${ARKIME_PRINT_CONFIG} ]; then
  cat $CONFIG
  exit 1
fi

case ${ARKIME_ENV} in
  "WISE" )
    cd wiseService/
    ../bin/node wiseService.js -c $CONFIG
    ;;
  "CAPTURE" )
    ARKIME_ELASTICSEARCH=$(echo ${ARKIME_ELASTICSEARCH} | cut -d "," -f1)
    if [[ -z $(curl -ss $ARKIME_ELASTICSEARCH/_cat/health) ]]; then 
      echo "unable to connect to elastic ${ARKIME_ELASTICSEARCH}" 
      exit 1
    fi
    if [[ `./db/db.pl ${ARKIME_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      if [[ -z "${ARKIME_DB_SHARDS}" ]]; then
        ARKIME_DB_SHARDS="3"
      fi
      if [[ -z "${ARKIME_DB_REPLICAS}" ]]; then
        ARKIME_DB_REPLICAS="0"
      fi
      if [[ -z "${ARKIME_DB_SHARDS_PER_NODE}" ]]; then
        ARKIME_DB_SHARDS_PER_NODE="null"
      fi
      echo "INIT" | ./db/db.pl ${ARKIME_ELASTICSEARCH} init --shards ${ARKIME_DB_SHARDS} --replicas ${ARKIME_DB_REPLICAS} --shardsPerNode ${ARKIME_DB_SHARDS_PER_NODE}
    fi
    ethtool -K $ARKIME_INTERFACE tx off sg off gro off gso off lro off tso off
    capture -c $CONFIG $@
    ;;
  "VIEWER" )
    cd viewer/
    ARKIME_ELASTICSEARCH=$(echo ${ARKIME_ELASTICSEARCH} | cut -d "," -f1)
    if [[ -z $(curl -ss $ARKIME_ELASTICSEARCH/_cat/health) ]]; then 
      echo "unable to connect to elastic ${ARKIME_ELASTICSEARCH}" 
      exit 1
    fi
    sleep 5
    if [[ `../db/db.pl ${ARKIME_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      echo "elastic connection to ${ARKIME_ELASTICSEARCH} OK, but database is missing. Please create."
      exit 1
    fi
    ../bin/node addUser.js -c $CONFIG ${ARKIME_ADMIN_USER:-arkime} ${ARKIME_ADMIN_USER:-arkime} ${ARKIME_ADMIN_PASS:-arkime} --admin
    ../bin/node viewer.js -c $CONFIG $@
    ;;
  *)
    echo "ARKIME_ENV undefined"
esac
