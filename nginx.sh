#!/bin/bash

# Update package list
apt-get update

# Install nginx
apt-get install -y nginx

# Start nginx service
systemctl start nginx
systemctl enable nginx

# Create a custom index page
echo "<h1>Hello from Terraform GCP Instance!</h1>" > /var/www/html/index.html
echo "<p>Nginx is running successfully.</p>" >> /var/www/html/index.html

# Display nginx status
systemctl status nginx
