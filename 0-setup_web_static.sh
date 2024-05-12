#!/usr/bin/env bash
# This script sets up web servers for the deployment of web_static. It includes installing Nginx,
# creating necessary directory structures, setting up a simple HTML file, and configuring Nginx.

# Run script as root to ensure proper permissions
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check if Nginx is installed and install if it is not
if ! command -v nginx &> /dev/null; then
    apt-get update
    apt-get -y install nginx
fi

# Create the necessary directories
mkdir -p /data/web_static/releases/test /data/web_static/shared

# Create a fake HTML file for testing
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" > /data/web_static/releases/test/index.html

# Ensure the symbolic link is correct; remove if exists and recreate
ln -sf /data/web_static/releases/test /data/web_static/current

# Recursively change ownership of the /data/ directory to the 'ubuntu' user and group
chown -R ubuntu:ubuntu /data/

# Configure Nginx to serve the content from the symbolic link
tee /etc/nginx/sites-available/web_static <<EOF > /dev/null
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
ln -sf /etc/nginx/sites-available/web_static /etc/nginx/sites-enabled/

# Reload Nginx to apply the changes
service nginx reload

# Exit successfully
exit 0
