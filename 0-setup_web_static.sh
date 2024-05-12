#!/usr/bin/env bash

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    # Install Nginx if not already installed
    sudo apt-get update
    sudo apt-get -y install nginx
fi

# Create necessary directories if they don't exist
sudo mkdir -p /data/web_static/releases/test
sudo mkdir -p /data/web_static/shared

# Create a fake HTML file for testing
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Create symbolic link /data/web_static/current
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to ubuntu user and group recursively
sudo chown -R ubuntu:ubuntu /data/

# Create a new Nginx configuration file for serving web_static content
config_file="/etc/nginx/sites-available/web_static"
sudo tee "$config_file" > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;
    # Add a custom header with the server's hostname
    add_header X-Served-By "$hostname";

    location / {
        try_files $uri $uri/ =404;
    }

    location /hbnb_static/ {
        alias /data/web_static/current/;
    }
}
EOF


# Create a symbolic link to enable the new configuration
sudo ln -sf "$config_file" /etc/nginx/sites-enabled/web_static
sudo rm -rf /etc/nginx/sites-enabled/defaults
# Restart Nginx
sudo service nginx restart

exit 0
