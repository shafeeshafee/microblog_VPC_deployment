#!/bin/bash

# Test
echo "You are connected to the Application Server"

# update and install deps
sudo apt update
sudo apt install -y python3-pip python3-venv git

# clone the repo, else update if need
if [ ! -d "/home/ubuntu/microblog_VPC_deployment" ]; then
    git clone https://github.com/shafeeshafee/microblog_VPC_deployment.git /home/ubuntu/microblog_VPC_deployment
else
    cd /home/ubuntu/microblog_VPC_deployment
    git pull origin main
fi

cd /home/ubuntu/microblog_VPC_deployment

# sets up venv
python3 -m venv venv
source venv/bin/activate

# install requirements
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn pymysql cryptography

# set environment variables
export FLASK_APP=microblog.py
export FLASK_ENV=production

# database migrations
flask db upgrade

# starts the application using Gunicorn via systemd
sudo systemctl restart microblog
