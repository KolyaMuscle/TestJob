#!/bin/bash
sudo apt-get update -y
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo bash -c 'echo " <h1>Hello World</h1> " >> /home/ubuntu/index.html'
sudo docker run  -d -p 8080:80 --name web -v /home/ubuntu:/usr/share/nginx/html nginx
