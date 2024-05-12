#!/usr/bin/env bash

# Check if Nginx is installed
if ! dpkg -s nginx &> /dev/null; then
    echo "Nginx is not installed. Installing Nginx now..."
    sudo apt-get update
    sudo apt-get -y install nginx
    echo "Nginx has been installed."
else
    echo "Nginx is already installed."
fi

# Ask user to continue with the configuration
read -p "Do you want to continue setting up the web environment? (yes/no): " answer
if [[ "$answer" != "yes" ]]; then
    echo "Setup aborted."
    exit 1
fi

# Create the required directories
sudo mkdir -p /data/web_static/releases/test
sudo mkdir -p /data/web_static/shared

# Create a fake HTML file
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html

# Create a symbolic link
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to the ubuntu user and group
sudo chown -R ubuntu:ubuntu /data/

# Update Nginx configuration to serve the content
sudo sed -i '/^http {/a \\tinclude /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
echo "server {
    listen 80;
    server_name _;
    location /hbnb_static {
        alias /data/web_static/current/;
    }
}" | sudo tee /etc/nginx/sites-available/web_static.conf

sudo ln -sf /etc/nginx/sites-available/web_static.conf /etc/nginx/sites-enabled/

# Restart Nginx to apply the changes
sudo service nginx restart

echo "Setup completed successfully."
exit 0
