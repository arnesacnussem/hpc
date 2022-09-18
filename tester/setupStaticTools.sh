#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
sudo cp -f "$BASEDIR/grafana.ini" /etc/grafana/grafana.ini
sudo cp -f "$BASEDIR/prometheus.yml" /etc/prometheus/prometheus.yml
sudo mkdir -p /var/run/prometheus/
sudo chmod 777 /var/run/prometheus/
sudo service grafana-server restart
sudo service prometheus restart
sudo service prometheus-pushgateway restart
