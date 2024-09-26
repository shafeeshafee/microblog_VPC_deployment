# Microblog VPC Deployment

## Purpose

In this project, the idea was to deploy a web application with a custom VPC. We're improving from the [previous project](https://github.com/shafeeshafee/microblog_EC2_deployment) by introducing network isolation, better security, and scalability. The way that was implemented was through creating a custom VPC with public and private subnets, setting up a NAT Gateway (for outbound internet access for things in the private subnet), configuring security groups, and having the deployment process walking through several instances within VPCs. Jenkins automates the entire deployment process for this CI/CD pipeline. There's also a Prometheus and Grafana server monitoring our application server with the help of Prometheus' node exporter.

## Systems Overview

![workload 4 systems overview](/static/images/screenshots/workload_4_diagram.png)

1. **Developer Pushes Code to GitHub:**

   - Code is updated in repo.

2. **Jenkins Detects Change:**

   - Jenkins pulls the latest code into `/home/ubuntu/microblog_VPC_deployment/` on the Jenkins Server.

3. **Build and Test:**

   - Jenkins runs build and test stages as defined in `Jenkinsfile`.

4. **Trigger Deployment:**

   - If tests pass, Jenkins executes `setup.sh` on the Web Server.

5. **`setup.sh` on Web Server:**

   - SSH into the Application Server using pem key.
   - Executes `start_app.sh` on the Application Server.

6. **`start_app.sh` on Application Server:**

   - Clones the repository into `/home/ubuntu/microblog_VPC_deployment/application_code/`.
   - Sets up the Python environment.
   - Installs dependencies.
   - Sets environment variables.
   - Starts the application with Gunicorn in the background.

   ![flow of deployment steps](/static/images/screenshots/instance-flow.jpg)

7. **Accessing the Application:**

   - Users access the application via the Web Server's public IP, which routes traffic to the Application Server.

8. **Monitoring:**

   - Prometheus and Grafana on the Monitoring Server collect and visualize metrics to ensure the application is running smoothly.

   ![prometheus targets](/static/images/screenshots/prometheus.png)

   ![microblog site running live](/static/images/screenshots/graf-1.png)

   ![microblog site running live](/static/images/screenshots/graf-2.png)

<br/>

<br />

## Steps To Create This Deployment

1. Grabbed application source code to use for deployment.
2. Set Up a Custom VPC
   - Created a custom VPC network control and security.
   - Created public and private subnets for secure network segmentation.
   - Attached an Internet Gateway and configured route tables to manage traffic.
3. Configured a NAT Gateway
   - Created a NAT Gateway to allow private instances secure internet access for updates without exposing them to inbound traffic.
4. VPC Peering
   - Created a VPC peering connection to have seamless communication between Jenkins and application servers.
5. Launched EC2 Instances
   - Jenkins Server: Launched an instance to automate CI/CD pipelines.
     Web Server: Deployed an instance to handle incoming requests with necessary access controls.
     Application Server: Set up a private instance to host the backend securely.
6. Configured Security Groups
   - Configured security groups with least privilege to control traffic, acting as virtual firewalls.
7. Configured SSH Access Between Servers
   - Configured secure SSH connections to enable automated deployments across instances.
8. Configured Nginx on the Web Server
   - Set up Nginx as a reverse proxy to handle and securely forward HTTP requests to our web server.
9. Created Deployment Scripts
   - Created scripts to automate application setup, installing deps/libraries, and deployment.
10. Fruits of Automation
    - Developed a Jenkinsfile that integrates a pipeline with build, test, security scanning, and deploy stages, automating the software delivery process.

<br/>

### Happy Jenkins Build

![jenkins pipeline](/static/images/screenshots/jenkins.png)

### Site Running Live

![microblog site running live](/static/images/screenshots/microblog-site.png)

11. Set Up Monitoring
    - Created monitoring tools in the Monitoring server to track system performance and proactively detect issues.

## Issues and Troubleshooting

- **Issue**: Was unable to SSH from the Jenkins Server in the default VPC to the Web Server in the custom VPC due to VPC isolation.

  - **Fix**: Created a VPC peering connection, updated route tables to allow traffic between the VPCs, and adjusted security groups to permit SSH access.

- **Issue**: Had connectivity issues due to restrictive security group rules and NACLs.

  - **Fix**: Reviewed and updated security groups and NACL to allow necessary inbound and outbound traffic.

- **Issue**: The Application Server was terminating after the Jenkins pipeline completed.

  - **Fix**: Added flags in application run command to manage the Gunicorn process, making sure it continues running regardless of the Jenkins pipeline steps.

- **Issue**: How do we securely manage configuration variables and sensitive data in scripts and configurations?

  - **Fix**: Used Jenkins' credential manager to store sensitive info and made use of environment variables.

- **Issue**: EC2 instance IP addresses changed upon instance restart, causing connectivity issues.
  - **Fix**: Made use of Elastic IP and Private IPs of instances.

## Optimization

### Advantages of Modularizing Deployment and Production Environments

1. By separating environments, we isolate potential errors, which sees to it that development and testing activities don't impact the prod environment.
2. Limits access to prod environments, reducing the risk of unauthorized changes and security breaches.
3. Controlled Testing: Allows for thorough testing in a staging environment before promoting changes to production.
4. Environments can be scaled and configured independently based on whatever they need.

### But...

- The current infrastructure introduces some separation by hosting the Jenkins server in a different VPC from the application servers. However, direct deployment from Jenkins to production servers without an intermediary environment poses risks, as well as noting that there isn't any dedicated staging environment for testing deployments before they reach production.

**Where we shine:**

- Improved network segmentation with public and private subnets.
- Enhanced security through controlled access and use of a NAT Gateway.
- Automated deployment pipeline facilitating continuous integration and deployment.

**Growth areas:**

- Lack of separate staging environment for testing and validation.
- Direct deployment to production increases risk of unintended impacts.
- Limited scalability and redundancy; single points of failure exist.

While the system demonstrates significant improvements, it requires further enhancements to be considered a robust, production-ready environment.

### Next Project

- **Environment Separation**:

  - Implement dev, staging, and production environments for risk reduction and thorough testing.

- **Infrastructure as Code (IaC)**:

  - Use Terraform or AWS CloudFormation for consistent, version-controlled infrastructure management. This is foreshadowing a future project I'll do where I deploy everything with Terraform 👀

- **Security Considerations**:

  - Apply least privilege principle with IAM roles
  - Use AWS Secrets Manager for sensitive data
  - Enforce MFA for admin access

- **Scalability, Fault Tolerance, and Availability**:

  - Implement Elastic Load Balancers
  - Set up Auto Scaling Groups

- **Continuous Testing**:

  - Integrate comprehensive testing in CI/CD pipeline for improved code quality.

- **Network Stability**:

  - Make use of Elastic IPs for critical instances
  - Leverage AWS Route 53 for DNS management

## Conclusion

This project, while not the most efficient in terms of modern deployment, provided an invaluable experience in advanced infrastructure setup and demonstrated the importance in building secure, scalable, and resilient systems. Moving forward in the next workload project, we'll shift gears as the focus will be on implementing the identified optimizations to further elevate the infrastructure's capability and resilience.
