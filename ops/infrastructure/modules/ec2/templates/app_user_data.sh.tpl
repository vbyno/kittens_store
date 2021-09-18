#!/bin/bash

yum update -y
# Docker
amazon-linux-extras install docker -y
usermod -a -G docker ec2-user
# Docker Compose
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

service docker start

cd /home/ec2-user/app
echo "DATABASE_URL = ${database_url}" > ./iplist.log
DATABASE_URL=${database_url} docker-compose -f docker-compose.prod.rds.yml up -d
