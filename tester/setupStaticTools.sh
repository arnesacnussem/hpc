#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
sudo cp -f "$BASEDIR/grafana.ini" /etc/grafana/grafana.ini
sudo cp -f "$BASEDIR/prometheus.yml" /etc/prometheus/prometheus.yml

mkdir prometheus_data
sudo rm -rf 
sudo ln -s prometheus_data /var/lib/prometheus/
sudo chmod 777 /var/lib/prometheus/
sudo mkdir -p /var/run/prometheus
sudo chmod 777 /var/run/prometheus/
sudo service grafana-server start &
sudo service prometheus restart
sudo service prometheus-pushgateway restart

echo -n "Creating grafana resources..."
dsUid=
while [ -z "$dsUid" ]
do
    curl --silent --location -g --request POST 'http://localhost:3000/api/datasources' \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --data-raw '{
        "name": "Prometheus",
        "type": "prometheus",
        "isDefault": true,
        "url": "http://localhost:9090",
        "access": "proxy"
    }'
    
    dsUid="$(curl --silent --location -g --request GET 'http://localhost:3000/api/datasources' \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' | jq -r '.[0].uid')"
    
    echo -n "."
    sleep 1
done
echo "ok"

curl --silent --location -g --request POST 'http://localhost:3000/api/dashboards/db' \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    -d "{\"dashboard\":$(sed 's/${DS_PROMETHEUS}/DATA_SOURCE_UID/g' grafana-dashboard.json | sed "s/DATA_SOURCE_UID/$dsUid/g" -)}"
echo

echo "Creating grafana resources...ok."
