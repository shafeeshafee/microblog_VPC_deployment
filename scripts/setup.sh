#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <APP_SERVER_IP>"
    exit 1
fi

# Variables
APP_SERVER_IP="$1"
APP_SERVER_KEY="/home/ubuntu/.ssh/app_server_key.pem"
REPO_URL="https://github.com/shafeeshafee/microblog_VPC_deployment.git"
REPO_DIR="/home/ubuntu/microblog_VPC_deployment"

# Clone the repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    cd "$REPO_DIR"
    git pull origin main
fi

# Copy start_app.sh to the Application Server
scp -i "$APP_SERVER_KEY" "$REPO_DIR/scripts/start_app.sh" ubuntu@"$APP_SERVER_IP":/home/ubuntu/

# Run start_app.sh on the Application Server
ssh -i "$APP_SERVER_KEY" ubuntu@"$APP_SERVER_IP" 'bash ~/start_app.sh'
