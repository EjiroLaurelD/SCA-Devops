#!/bin/bash

# Set variables
nginx_version="1.23.3"
download_url="https://nginx.org/download/nginx-${nginx_version}.tar.gz"

# Update package list and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential libpcre3 libpcre3-dev zlib1g libgd-dev zlib1g-dev libssl-dev cron -y

# Create Nginx user and group
sudo groupadd -r nginx && sudo useradd -r -g nginx nginx

# Download Nginx source code
wget $download_url 

# Extract the downloaded archive
tar -xzvf nginx-${nginx_version}.tar.gz 

# Change directory to the extracted folder
cd nginx-${nginx_version} 

# Set error handling
#sudo set -e

# Configure Nginx with necessary options
# Adjust this line with your preferred configuration options
./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module

# Build and install Nginx
make && sudo make install |

# Create a temporary directory
temp_dir=$(mktemp -d)

# Create the service file
sudo bash -c cat << EOF > "$temp_dir/nginx.service"
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
        
[Service]
Type=forking
User=nginx
Group=nginx
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

# Set ownership of the service file
sudo chown root:root "$temp_dir/nginx.service"

# Copy the service file to the systemd directory
sudo cp "$temp_dir/nginx.service" /etc/systemd/system/

# Change Nginx binary ownership
sudo chown -R nginx:nginx /usr/sbin/nginx

# Reload systemd
sudo systemctl daemon-reload

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx service to start at boot
sudo systemctl enable nginx

# Cleanup temporary directory
rm -rf "$temp_dir"

echo "Nginx installation completed successfully!"

# add cron job to back up Nginx configuration files to home directory everyday
