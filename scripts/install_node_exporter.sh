#!/bin/bash

# TODO: automate this in pipeline, did this manually on Monitoring server

# change the version to latest
NODE_EXPORTER_VERSION="1.8.2"

DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"

sudo apt update
sudo apt install -y wget tar

# create a dedicated user for least privelage
# we run node exporter not as root, but as an isolated limited user
sudo useradd --no-create-home --shell /bin/false node_exporter

# download and extract the Node Exporter
wget $DOWNLOAD_URL
tar xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64

# this command gives ownership of the Node Exporter binary to the node_exporter user and group, meaning only this user (and members of the node_exporter group) can manage or execute it
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# create the service in systemd
sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

# starts and enables the service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
