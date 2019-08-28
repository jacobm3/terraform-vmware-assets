#!/bin/bash -x

apt-get update
apt-get install -y cowsay nginx
chown -R ptfeadmin /var/www/html
