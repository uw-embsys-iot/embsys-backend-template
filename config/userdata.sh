#! /bin/bash
set -e
set -x

# Ouput all log
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Get all latest packages and install python virtualenv
sudo apt update -y

# It's very unlikely that you actually need to upgrade, and it takes a long time.
# However, it's a good way to catch what's happening at startup. To do this,
# SSH into the instance, and run "tail -f /var/log/user-data.log"
# sudo apt upgrade -y
sudo apt install -y python3-venv

# There are other ways of installing, as well
# https://nodejs.org/en/download/package-manager#debian-and-ubuntu-based-linux-distributions
#sudo apt install -y nodejs
#sudo apt install -y npm

# Install docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce docker-compose-plugin

# If something isn't working with grafana or graphite, check that docker is running
# sudo systemctl status docker

echo 'Done package update and install'

# Fetch the repository containing the source and configs
git clone https://github.com/kail/embsys-backend.git server
cd server
git fetch origin final
git checkout final
echo 'Done fetching repository'

# Start graphite and grafana via docker compose
sudo docker volume create --name=grafana-volume
sudo docker compose -f config/docker-compose.yml up -d

# Install and run graphite
# https://hub.docker.com/r/graphiteapp/graphite-statsd/
# sudo docker run -d \
#  --name graphite \
#  --restart=always \
#  -p 80:80 \
#  -p 2003-2004:2003-2004 \
#  -p 2023-2024:2023-2024 \
#  -p 8125:8125/udp \
#  -p 8126:8126 \
#  graphiteapp/graphite-statsd

# Run grafana server
# Note: instance must be restarted
# Note the datasource must be set up manually: https://grafana.com/docs/grafana/latest/datasources/graphite/
# TODO(mskobov): Figure out which services must be restarted for grafana to work
# sudo docker run -d --name=grafana --restart=always -p 3000:3000 grafana/grafana

# Start statsd server
#git clone https://github.com/statsd/statsd.git /srv/statsd
#node /srv/statsd/stats.js config/statsd_config.js&
#echo 'Done starting statsd'

# Configure Cloudwatch agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Start the cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-s \
-c file:config/cloudwatch_agent_conf.json

echo 'Done cloudwatch initialization'

# Start the service
cd server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 server.py&

echo 'Done launching server'
