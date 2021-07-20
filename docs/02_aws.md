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

1. Create Image

Read the logs

```
tail -f /var/log/cloud-init-output.log
```
