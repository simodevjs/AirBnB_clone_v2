#!/usr/bin/env bash
# This script sets up web servers for the deployment of web_static. It includes installing Nginx,
# creating necessary directory structures, setting up a simple HTML file, and configuring Nginx.

# Check if Nginx is installed and install if it is not
if ! command -v nginx &> /dev/null; then
    sudo apt-get update
    sudo apt-get -y install nginx
fi

# Create the necessary directories
sudo mkdir -p /data/web_static/releases/test /data/web_static/shared

# Create a fake HTML file for testing
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Ensure the symbolic link is correct; remove if exists and recreate
sudo ln -sf /data/web_static/releases/test /data/web_static/current

# Recursively change ownership of the /data/ directory to the 'ubuntu' user and group
sudo chown -R ubuntu:ubuntu /data/

# Configure Nginx to serve the content from the symbolic link
sudo tee /etc/nginx/sites-available/web_static > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/html;

    location /hbnb_static {
        alias /data/web_static/current/;
        index index.html index.htm;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable the configuration by linking to the sites-enabled directory
sudo ln -sf /etc/nginx/sites-available/web_static /etc/nginx/sites-enabled/
sudo rm -rf /etc/nginx/sites-enabled/defaults
# Reload Nginx to apply the changes
sudo service nginx reload

# Exit successfully
exit 0
