
# Deploy Terraform with GitHub Actions

This repository contains a GitHub Actions workflow to deploy infrastructure using Terraform. The workflow automates the process of setting up AWS resources, specifically an ECS Fargate service, using Terraform configurations.

## Workflow Overview

The GitHub Actions workflow is triggered on every push to the `main` branch. It performs the following steps:

1. **Checkout Code**: Checks out the repository code.
2. **Configure AWS Credentials**: Configures AWS credentials using secrets stored in GitHub.
3. **Set up Terraform**: Sets up Terraform with the specified version.
4. **Terraform Init**: Initializes the Terraform configuration.
5. **Terraform Plan**: Generates a Terraform execution plan.
6. **Terraform Apply**: Applies the Terraform configuration to create or update the infrastructure.

## Terraform Configuration

### main.tf

Defines the AWS provider, backend configuration, and resources to be created:

- **AWS Provider**: Specifies the AWS region.
- **Backend Configuration**: Configures the S3 bucket for storing the Terraform state file.
- **VPC and Subnets**: Creates a VPC and two subnets in different availability zones.
- **Security Group**: Creates a security group to control inbound and outbound traffic.
- **ECS Cluster**: Creates an ECS cluster named "fargate-cluster".
- **IAM Role**: Creates an IAM role for ECS task execution with the necessary policies.
- **ECS Task Definition**: Defines an ECS task for Fargate with specified resources and container settings.
- **ECS Service**: Creates an ECS service to run the Fargate task.
- **EventBridge Rule and Target**: Schedules the ECS task to run periodically using EventBridge.
- **IAM Role Policy**: Allows EventBridge to invoke ECS tasks by attaching the necessary policy to the IAM role.

### terraform.tfvars

Specifies the values for the variables used in the Terraform configuration:

- `s3_bucket`: The name of the S3 bucket for deployment.
- `s3_key`: The name of the ZIP file in the S3 bucket.
- `lambda_handler`: The Lambda function handler name.

### variables.tf

Defines the variables used in the Terraform configuration:

- `s3_bucket`: Description and type of the S3 bucket variable.
- `s3_key`: Description and type of the S3 key variable.
- `lambda_handler`: Description and type of the Lambda handler variable.

### factorial.py

A simple Python script to calculate the factorial of a given number:

```python
import sys

def factorial(n):
    if n == 0 or n == 1:
        return 1
    else:
        return n * factorial(n - 1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python factorial.py <number>")
    else:
        number = int(sys.argv[1])
        result = factorial(number)
        print(f"The factorial of {number} is {result}")
```

### Dockerfile

Defines a Docker image for running the Python script:

```dockerfile
# Use official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script into the container
COPY factorial.py .

# Set the default command to run the Python script
CMD ["python", "factorial.py", "5"]
```

## Usage

1. **Set up Secrets**: Add your AWS credentials (`AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`) as secrets in your GitHub repository.
2. **Push to Main Branch**: Push your changes to the `main` branch to trigger the workflow.
3. **Monitor Workflow**: Monitor the GitHub Actions workflow to ensure successful deployment.

## Summary

This repository automates the deployment of an ECS Fargate service using Terraform and GitHub Actions. By following the steps outlined in this `README.md`, you can easily set up and manage your infrastructure as code.

Feel free to customize the Terraform configurations and workflow as per your requirements.

Happy deploying!
```

Let me know if there's anything else you'd like to add or modify!
