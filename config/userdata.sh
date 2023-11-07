#! /bin/bash
set -e
set -x

# Ouput all log
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Get all latest packages and install python virtualenv
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3-venv
echo 'Done package update'

# Fetch the repository containing the source and configs
git clone https://github.com/kail/embsys-backend.git server
cd server
git fetch origin final
git checkout final
cd server
echo 'Done fetching repository'

# Configure Cloudwatch agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Use cloudwatch config from SSM
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-s \
-c file:config/cloudwatch_agent_conf.json

echo 'Done cloudwatch initialization'


python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 server.py&

echo 'Done launching server'
