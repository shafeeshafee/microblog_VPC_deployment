pipeline {
    agent any
    environment {
        WEB_SERVER_IP = credentials('web-server-private-ip')
    }
    stages {
        stage('Build') {
            steps {
                sh '''
                #!/bin/bash
                # Update and install Python dependencies
                sudo apt-get update
                sudo apt-get install -y python3-pip build-essential python3-venv

                python3 -m venv venv
                source venv/bin/activate

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
                sshagent(['web-server-ssh-credentials']) {
                    sh '''
                    #!/bin/bash

                    # copies setup.sh to the web server
                    scp scripts/setup.sh ubuntu@$WEB_SERVER_IP:/home/ubuntu/

                    # runs setup.sh on the web server
                    ssh ubuntu@$WEB_SERVER_IP 'bash ~/setup.sh'
                    '''
                }
            }
        }
    }
}