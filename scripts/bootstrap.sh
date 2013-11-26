#!/usr/bin/env bash

SCRIPTS_DIR=$(cd $(dirname $0); pwd) # absolute dir
ROOT_DIR=$(dirname $SCRIPTS_DIR)

INSTALL_DIR="/s/code/services/elasticsearch"
KATO_CONFIG_DIR="/s/etc/kato"

# Stop supervisord for reconfiguration
stop-supervisord

# Copy elasticsearch to the services folder and install gems
cp -R $ROOT_DIR $INSTALL_DIR
cd $INSTALL_DIR && bundle install

# Copy configuration files
cp -R etc/* /s/etc/

# Restart supervisord and kato
start-supervisord
kato start

# Add the authentication token to the config
SERVICE_TOKEN=$(python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)')
echo "token: $SERVICE_TOKEN" >> $INSTALL_DIR/config/gateway.yml

# set kato config
cat $INSTALL_DIR/config/gateway.yml | kato config set elasticsearch_gateway / --yaml
cat $INSTALL_DIR/config/node.yml | kato config set elasticsearch_node / --yaml

# Add the authentication token to the cloud controller
kato config set cloud_controller_ng builtin_services/elasticsearch/token $SERVICE_TOKEN

# Add the role to kato
kato role add elasticsearch
