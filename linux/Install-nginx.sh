#!/bin/bash

# Set variables
nginx_version="1.23.3"
download_url="https://nginx.org/download/nginx-${nginx_version}.tar.gz"

# Update package list and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential libpcre3 libpcre3-dev zlib1g libgd-dev zlib1g-dev libssl-dev cron -y

# Download Nginx source code
wget $download_url

# Extract the downloaded archive
tar -xzvf nginx-${nginx_version}.tar.gz

# Change directory to the extracted folder
cd nginx-${nginx_version}

# Configure Nginx with necessary options
#./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_v2_module
./configure --user=nginx --group=nginx --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module

# Build and install Nginx
make && sudo make install

# create an Nginx systemd service unit
#sudo cat << EOF > "$temp_dir/nginx.service"
sudo bash -c 'cat > /etc/systemd/system/nginx.service' <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
        
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
Restart=on-failure
RestartSec=3
        
[Install]
WantedBy=multi-user.target
EOF

# Change Nginx user
sudo chown -R nginx:nginx /usr/sbin/nginx

#sudo systemctl daemon-reload
 
# reload systemd daemon
sudo systemctl daemon-reload

# start Nginx service
sudo systemctl start nginx

# enable Nginx service to start at boot
sudo systemctl enable nginx
