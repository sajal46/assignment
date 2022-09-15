#! /bin/bash
cat /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF
sudo yum install -y mongodb-org -y
sudo systemctl start mongod


mongo --eval 'db.createUser({user: "mongodb_exporter", pwd: "ZzExgqVz12", roles: [{ role: "clusterMonitor", db: "admin" },{ role: "read", db: "local" }]})'


wget https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz

tar -xvzf node_exporter-0.15.1.linux-amd64.tar.gz .

mv node_exporter-0.15.1.linux-amd64 node-exporter

mv node-exporter/node_exporter /usr/bin/

sudo useradd --no-create-home --shell /bin/false exporter

cat /etc/systemd/system/node-exporter.service <<EOF
[Unit]
Description=Node Exporter

[Service]
User=exporter
Group=exporter
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=default.target
EOF

wget https://github.com/percona/mongodb_exporter/releases/download/v0.34.0/mongodb_exporter-0.34.0.linux-amd64.tar.gz

tar xvzf mongodb_exporter-0.34.0.linux-amd64.tar.gz

sudo mv mongodb_exporter /usr/local/bin/mongodb-exporter

sudo chown exporter:exporter /usr/local/bin/mongodb-exporter

cat /etc/systemd/system/mongo-exporter.service <<EOF
[Unit]
Description=Mongodb Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=exporter
Group=exporter
Type=simple
ExecStart=/usr/local/bin/mongodb-exporter --mongodb.uri=mongodb://mongodb_exporter:ZzExgqVz12@localhost:27017 --collect-all

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload

sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter

sudo systemctl enable mongo-exporter
sudo systemctl start mongo-exporter
sudo systemctl status mongo-exporter

sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl status mongod