#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <APP_SERVER_IP>"
    exit 1
fi

# Variables
APP_SERVER_IP="$1"
APP_SERVER_KEY="/home/ubuntu/.ssh/app_server_key.pem"

# Copy start_app.sh to the Application Server
scp -i "$APP_SERVER_KEY" ~/microblog_VPC_deployment/scripts/start_app.sh ubuntu@"$APP_SERVER_IP":/home/ubuntu/

# Run start_app.sh on the Application Server
ssh -i "$APP_SERVER_KEY" ubuntu@"$APP_SERVER_IP" 'bash ~/start_app.sh'
