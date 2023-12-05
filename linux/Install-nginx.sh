#!/bin/bash
# update package repository
sudo apt update -y

# install build essentials and dependencies
sudo apt install build-essential libmaxminddb0 libmaxminddb-dev mmdb-bin checkinstall ufw -y

# create directory to store nginx source file
sudo mkdir -p /opt/nginx && cd /opt/nginx

# download nginx source code
wget http://nginx.org/download/nginx-1.20.2.tar.gz

# extract source code
tar -zxvf nginx-1.20.2.tar.gz

# configure nginx
cd nginx-1.20.2
./configure --user=nginx --group=nginx --prefix=/opt/nginx --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock

# build nginx
make

# install nginx
sudo make install

# create an Nginx systemd service unit
sudo cat << EOF >/etc/systemd/system/nginx.service
[Unit]
Description=Nginx web server
After=network.target

[Service]
Type=simple
User=nginx
Group=nginx
ExecStart=/opt/nginx/sbin/nginx
ExecReload=/opt/nginx/sbin/nginx -s reload
PrivateTmp=true
RuntimeDirectory=/opt/nginx

[Install]
WantedBy=multi-user.target
EOF

# reload systemd daemon
sudo systemctl daemon-reload

# start Nginx service
sudo systemctl start nginx

# enable Nginx service to start at boot
sudo systemctl enable nginx

# add cron job to back up Nginx configuration files to home directory everyday
echo "0 0 * * * sudo cp -rf /opt/nginx/conf/* ~/nginx-backup/" | sudo crontab -l -
