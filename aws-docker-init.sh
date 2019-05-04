#!/bin/bash

sudo yum -y update
sudo yum -y install docker git
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker pull sameersbn/redmine:3.3.4
wget https://raw.githubusercontent.com/sameersbn/docker-redmine/master/docker-compose.yml
