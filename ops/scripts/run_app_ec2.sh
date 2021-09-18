#!/bin/sh

cd ~/app || exit
docker-compose -f docker-compose.prod.yml up -d
