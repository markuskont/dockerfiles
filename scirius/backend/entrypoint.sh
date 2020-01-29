#!/bin/bash
SCIRIUS_CONF=scirius/local_settings.py
touch $SCIRIUS_CONF

echo 'ELASTICSEARCH_LOGSTASH_INDEX = "suricata-"'  >> $SCIRIUS_CONF
echo 'ELASTICSEARCH_LOGSTASH_ALERT_INDEX = "suricata-"'  >> $SCIRIUS_CONF
echo 'ELASTICSEARCH_VERSION = 7'  >> $SCIRIUS_CONF
echo 'ELASTICSEARCH_KEYWORD = "keyword"'  >> $SCIRIUS_CONF
echo 'ELASTICSEARCH_LOGSTASH_TIMESTAMPING = "daily"'  >> $SCIRIUS_CONF
echo "ELASTICSEARCH_HOSTNAME = \"$EXPOSE\"" >> $SCIRIUS_CONF

echo "ALLOWED_HOSTS = [\"localhost\", \"$EXPOSE\"]"  >> $SCIRIUS_CONF
echo 'SURICATA_NAME_IS_HOSTNAME = True'  >> $SCIRIUS_CONF
echo 'USE_KIBANA = True' >> $SCIRIUS_CONF
echo "KIBANA_URL = \"http://$EXPOSE:5601\"" >> $SCIRIUS_CONF
echo 'KIBANA_INDEX = ".kibana"' >> $SCIRIUS_CONF
echo "USE_EVEBOX = True" >> $SCIRIUS_CONF
echo "EVEBOX_ADDRESS = \"$EXPOSE:5636\"" >> $SCIRIUS_CONF

gunicorn -t 600 -w 4 --bind unix:/var/run/scirius/scirius.sock scirius.wsgi:application
