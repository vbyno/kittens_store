chmod 400 ../keypair-devops-bootcamp.pem
ssh -i ../keypair-devops-bootcamp.pem ec2-user@ec2-54-219-157-209.us-west-1.compute.amazonaws.com

```bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chmod 666 /var/run/docker.sock

RACK_ENV=development DATABASE_NAME=kittens_store_dev docker-compose up

Instance Settings => Edit user data

1. Create Image

2. Add LBs security group to EC2 instances security group as a 80 port connection point

3. Read the logs

```
docker logs -f 561fa407d1fa
```

Autoscaling:
Create launch template for autoscaling group
launch template -> advanced -> user data
```bash
#!/bin/bash

sudo service docker start

cd /home/ec2-user/kittens_store
sudo docker-compose up
```

Create autoscaling group
