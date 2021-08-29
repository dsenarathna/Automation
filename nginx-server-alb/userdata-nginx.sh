#! /bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Hello World | This is server $(hostname -f)" | sudo tee /var/www/html/index.html
