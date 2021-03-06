#!/bin/bash

case ${MOLOCH_ENV} in
  "WISE" )
    CONFIG=/data/moloch/etc/wise.ini
    if [[ ! -f $CONFIG ]]; then
      echo "creating wise config file"
      cp $CONFIG.sample $CONFIG
    fi
    ;;
  *)
    CONFIG=/data/moloch/etc/config.ini
    if [[ ! -f $CONFIG ]]; then
      cp $CONFIG.sample $CONFIG

      MOLOCH_CAPTURE_PLUGINS="wise.so"
      if [[ ! -z ${MOLOCH_SURICATA_FILE} ]]; then
        MOLOCH_CAPTURE_PLUGINS+=";suricata.so"
      fi

      sed -i "s,dropUser=nobody,dropUser=moloch,g"                                    $CONFIG
      sed -i "s,MOLOCH_INSTALL_DIR,/data/moloch,g"                                    $CONFIG

      sed -i -e "s,# plugins=tagger.so; netflow.so,plugins=${MOLOCH_CAPTURE_PLUGINS},g"                                         $CONFIG
      sed -i -e "s,# viewerPlugins=wise.js,viewerPlugins=wise.js\nwiseTcpTupleLookups=true\nwiseUdpTupleLookups=true\n,g"   $CONFIG

      if [[ -n ${MOLOCH_SURICATA_FILE} ]]; then
        grep "suricataAlertFile" $CONFIG || sed -i -e "/plugins=${MOLOCH_CAPTURE_PLUGINS}/asuricataAlertFile=${MOLOCH_SURICATA_FILE}" $CONFIG
      fi
      if [[ -z ${MOLOCH_WISE_PORT} ]]; then
        MOLOCH_WISE_PORT=8081
      fi
      if [[ -z "${MOLOCH_ELASTICSEARCH}" ]]; then
        MOLOCH_ELASTICSEARCH="moloch-elastic:9200"
      fi
      if [[ -z "${MOLOCH_INTERFACE}" ]]; then
        MOLOCH_INTERFACE="eth0"
      fi
      if [[ -z "${MOLOCH_PASSWORD}" ]]; then
        MOLOCH_PASSWORD="D0ker1z3dd#"
      fi
      if [[ -n "${MOLOCH_WISE_HOST}" ]]; then
        sed -i -e "s,#wiseHost=127.0.0.1,wiseHost=${MOLOCH_WISE_HOST}\nwisePort=${MOLOCH_WISE_PORT}\n,g" $CONFIG
        #sed -i -e "s/#wiseHost=127.0.0.1/wiseHost=${MOLOCH_WISE_HOST}\nwiseCacheSecs=600\nplugins=wise.so\nviewerPlugins=wise.js\nwiseTcpTupleLookups=true\nwiseUdpTupleLookups=true\n/g" $CONFIG
      fi
      if [[ -n "${MOLOCH_PACKET_THREADS}" ]]; then
        sed -i -e "s/packetThreads=2/packetThreads=${MOLOCH_PACKET_THREADS}/g" $CONFIG
      fi
      if [[ -n "${MOLOCH_INCLUDES}" ]]; then
        sed -i -e "s,#includes=,includes=${MOLOCH_INCLUDES},g" $CONFIG || exit 1
      fi
      if [[ -n "${MOLOCH_READ_TRUNCATED}" ]]; then
        sed -i '/\[default\]/areadTruncatedPackets=true' $CONFIG
      fi
      sed -i "s/MOLOCH_ELASTICSEARCH/${MOLOCH_ELASTICSEARCH}/g" $CONFIG
      sed -i "s/MOLOCH_INTERFACE/${MOLOCH_INTERFACE}/g"         $CONFIG
      sed -i "s/MOLOCH_PASSWORD/${MOLOCH_PASSWORD}/g"           $CONFIG
    fi
    ;;
esac

if [ ${MOLOCH_PRINT_CONFIG} ]; then
  cat $CONFIG
  exit 1
fi

case ${MOLOCH_ENV} in
  "WISE" )
    ../bin/node wiseService.js -c $CONFIG
    ;;
  "CAPTURE" )
    MOLOCH_ELASTICSEARCH=$(echo ${MOLOCH_ELASTICSEARCH} | cut -d "," -f1)
    if [[ -z $(curl -ss $MOLOCH_ELASTICSEARCH/_cat/health) ]]; then 
      echo "unable to connect to elastic ${MOLOCH_ELASTICSEARCH}" 
      exit 1
    fi
    if [[ `./db/db.pl ${MOLOCH_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      if [[ -z "${MOLOCH_DB_SHARDS}" ]]; then
        MOLOCH_DB_SHARDS="3"
      fi
      if [[ -z "${MOLOCH_DB_REPLICAS}" ]]; then
        MOLOCH_DB_REPLICAS="0"
      fi
      if [[ -z "${MOLOCH_DB_SHARDS_PER_NODE}" ]]; then
        MOLOCH_DB_SHARDS_PER_NODE="null"
      fi
      echo "INIT" | ./db/db.pl ${MOLOCH_ELASTICSEARCH} init --shards ${MOLOCH_DB_SHARDS} --replicas ${MOLOCH_DB_REPLICAS} --shardsPerNode ${MOLOCH_DB_SHARDS_PER_NODE}
    fi
    moloch-capture -c $CONFIG $@
    ;;
  "VIEWER" )
    MOLOCH_ELASTICSEARCH=$(echo ${MOLOCH_ELASTICSEARCH} | cut -d "," -f1)
    if [[ -z $(curl -ss $MOLOCH_ELASTICSEARCH/_cat/health) ]]; then 
      echo "unable to connect to elastic ${MOLOCH_ELASTICSEARCH}" 
      exit 1
    fi
    if [[ `../db/db.pl ${MOLOCH_ELASTICSEARCH} info | grep "DB Version" | cut -d ":" -f2 | tr -d " "` -eq -1 ]]; then
      echo "elastic connection to ${MOLOCH_ELASTICSEARCH} OK, but database is missing. Please create."
      exit 1
    fi
    if [[ -n "${MOLOCH_ADMIN_USER}" ]]; then
      if [[ -z ${MOLOCH_ADMIN_PASS} ]]; then
        MOLOCH_ADMIN_PASS=${MOLOCH_ADMIN_USER}
      fi
      ../bin/node addUser.js -c $CONFIG ${MOLOCH_ADMIN_USER} ${MOLOCH_ADMIN_USER} ${MOLOCH_ADMIN_PASS} --admin
    fi
    ../bin/node viewer.js -c $CONFIG $@
    ;;
  *)
    echo "MOLOCH_ENV undefined"
esac
