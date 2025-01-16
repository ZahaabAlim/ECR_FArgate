
# Deploy Terraform with GitHub Actions

Welcome! This repository helps you automatically set up and manage AWS resources using Terraform and GitHub Actions. Even if you're new to these tools, this guide will walk you through everything you need to know.

## What Does This Repository Do?

This repository automates the process of deploying an application to AWS. It uses Terraform to define the infrastructure and GitHub Actions to automate the deployment process. Here's a simple breakdown:

1. **Terraform**: A tool that lets you define your cloud resources (like servers, databases, etc.) in code.
2. **GitHub Actions**: A service that automates tasks, like deploying your application, whenever you push code to your repository.

## How It Works

### GitHub Actions Workflow

When you push code to the `main` branch, GitHub Actions will:

1. **Checkout Code**: Get the latest code from your repository.
2. **Configure AWS Credentials**: Set up AWS access using secret keys stored in GitHub.
3. **Set up Terraform**: Install Terraform, a tool for managing infrastructure.
4. **Terraform Init**: Prepare Terraform to work with your configuration.
5. **Terraform Plan**: Create a plan showing what changes Terraform will make.
6. **Terraform Apply**: Apply the changes to set up or update your AWS resources.

### Terraform Configuration (main.tf)

This file defines the AWS resources you need:

1. **AWS Provider**: Specifies the AWS region where your resources will be created.
2. **Backend Configuration**: Uses an S3 bucket to store the state of your Terraform-managed infrastructure.
3. **VPC and Subnets**: Creates a virtual network (VPC) and two smaller networks (subnets) within it.
4. **Security Group**: Sets up rules for what traffic is allowed in and out of your network.
5. **ECS Cluster**: Creates a cluster to run your containerized applications.
6. **IAM Role**: Defines permissions for your ECS tasks to interact with other AWS services.
7. **ECS Task Definition**: Specifies the details of the containerized application, including the Docker image to use.
8. **ECS Service**: Runs the specified task on the ECS cluster.
9. **EventBridge Rule and Target**: Schedules the ECS task to run periodically.
10. **IAM Role Policy**: Grants permissions for EventBridge to start ECS tasks.

### Python Script (factorial.py)

A simple Python script that calculates the factorial of a given number. For example, the factorial of 5 is 5 x 4 x 3 x 2 x 1 = 120.

### Dockerfile

Defines a Docker image that runs the Python script. It uses a lightweight Python image, sets up the working directory, copies the script into the container, and specifies the command to run the script.

## How to Use This Repository

1. **Set up Secrets**: Add your AWS credentials (`AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`) as secrets in your GitHub repository.
2. **Push to Main Branch**: Push your changes to the `main` branch to trigger the workflow.
3. **Monitor Workflow**: Check the GitHub Actions tab in your repository to see the progress and ensure everything is deployed successfully.

## Summary

This repository helps you deploy your application to AWS quickly and reliably, with minimal manual effort. It ensures that your infrastructure is always up-to-date and consistent, making your development and deployment process smoother and more efficient.

### Key Benefits

1. **Automates AWS Setup**: Automatically creates and manages AWS resources.
2. **Deploys Applications Easily**: Deploys your application to AWS with minimal manual effort.
3. **Ensures Consistency**: Keeps your infrastructure consistent and up-to-date with every code change.
4. **Saves Time**: Reduces the need for manual setup, allowing you to focus on development.


