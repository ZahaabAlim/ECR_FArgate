# Configure the S3 backend for storing Terraform state
terraform {
  backend "s3" {
    bucket         = "tf-backend-st1"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TfState"
    encrypt        = true
  }
}

# Define the AWS provider and region
provider "aws" {
  region     = "us-east-1"
}

# Create a VPC with a /16 CIDR block
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create the first subnet in the VPC
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create the second subnet in the VPC
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create a security group for ECS with open ingress and egress rules
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ECS cluster named "fargate-cluster"
resource "aws_ecs_cluster" "fargate_cluster" {
    name = "fargate-cluster"
}

# Create an IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
            Service = "ecs-tasks.amazonaws.com"
        }
        }]
    })
    managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

# Define an ECS task definition for a Fargate task
resource "aws_ecs_task_definition" "fargate_task" {
    family                   = "fargate-task"
    cpu                      = 256
    memory                   = 512
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([{
        name = "factorial-app"
        image = "471112883895.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo:v0.0.1"
        cpu = 256
        memory = 512
        essential = true
    }])

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
}

# Create an ECS service to run the Fargate task
resource "aws_ecs_service" "fargate_service" {
    name            = "fargate-service"
    cluster         = aws_ecs_cluster.fargate_cluster.id
    task_definition = aws_ecs_task_definition.fargate_task.arn
    launch_type     = "FARGATE"
    network_configuration {
    subnets         = [aws_subnet.subnet1.id, aws_subnet2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}
