#!/usr/bin/env bash

SCRIPTS_DIR=$(cd $(dirname $0); pwd) # absolute path
ROOT_DIR=$(dirname $SCRIPTS_DIR)

ES_VERSION="0.90.7"

INSTALL_DIR="/opt/elasticsearch"

# fail fast and fail hard
set -eo pipefail

# install prerequisites for elasticsearch
apt-get update
apt-get install -y openjdk-7-jre-headless

# install elasticsearch
curl https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.tar.gz | tar -xz
mv elasticsearch-$ES_VERSION $INSTALL_DIR
chown -R stackato:stackato $INSTALL_DIR

# copy the local config files
rm $INSTALL_DIR/config/*.yml
cp $ROOT_DIR/resources/*.yml $INSTALL_DIR/config/

# copy the upstart script
cp $ROOT_DIR/resources/elasticsearch.conf /etc/init

# start the upstart process
start elasticsearch
