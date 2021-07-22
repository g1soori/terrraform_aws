#!/bin/bash
amazon-linux-extras install nginx1 -y
amazon-linux-extras enable nginx1
systemctl start nginx
curl http://169.254.169.254/latest/meta-data/instance-id > /usr/share/nginx/html/index.html 