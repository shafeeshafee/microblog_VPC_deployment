pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y python3-pip build-essential python3-venv
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''#!/bin/bash
                    source venv/bin/activate
                    mkdir -p test-reports
                    python -m pytest tests.py --verbose --junit-xml=test-reports/results.xml
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format "XML" --out .', odcInstallation: 'DP-Check'
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'web-server-private-ip', variable: 'WEB_SERVER_IP'),
                    string(credentialsId: 'app-server-private-ip', variable: 'APP_SERVER_IP')
                ]) {
                    sshagent(['web-server-ssh-credentials']) {
                        sh '''
                        #!/bin/bash
                        # create the .ssh directory if doesn't exist 
                        mkdir -p ~/.ssh

                        # Check if the Web Server's host key is already in known_hosts
                        if ! ssh-keygen -F $WEB_SERVER_IP > /dev/null; then
                            echo "Adding $WEB_SERVER_IP to known_hosts"
                            ssh-keyscan -H $WEB_SERVER_IP >> ~/.ssh/known_hosts
                        else
                            echo "$WEB_SERVER_IP is already in known_hosts"
                        fi

                        # continue with SCP and SSH commands
                        scp scripts/setup.sh ubuntu@$WEB_SERVER_IP:/home/ubuntu/
                        ssh ubuntu@$WEB_SERVER_IP "bash ~/setup.sh \\"$APP_SERVER_IP\\""
                        '''
                    }
                }
            }
        }
    }
}
