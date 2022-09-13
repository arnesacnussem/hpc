#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

sudo apt update
sudo apt-get install -y gnupg2 curl software-properties-common
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update
sudo apt-get -y install grafana prometheus prometheus-pushgateway


sudo cp -f "$BASEDIR/grafana.ini" /etc/grafana/grafana.ini
sudo cp -f "$BASEDIR/prometheus.yml" /etc/prometheus/prometheus.yml
sudo mkdir -p /var/run/prometheus/
sudo chmod 777 /var/run/prometheus/
sudo service grafana-server restart
sudo service prometheus restart
sudo service prometheus-pushgateway restart
