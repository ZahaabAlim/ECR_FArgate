# Configure the backend to store the Terraform state in an S3 bucket
terraform {
  backend "s3" {
    bucket         = "tf-backend-st1"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "TfStatelock"  # Uncomment to use DynamoDB for state locking
    # encrypt        = true           # Uncomment to enable encryption for the state file
  }
}

# Set up the AWS provider and specify the region
provider "aws" {
  region     = "us-east-1"
}

# Create a Virtual Private Cloud (VPC) with a specified CIDR block
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet within the VPC in the specified availability zone
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create another subnet within the VPC in a different availability zone
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create a security group within the VPC to control inbound and outbound traffic
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow incoming traffic on port 80 from any IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Create an ECS cluster named "fargate-cluster"
resource "aws_ecs_cluster" "fargate_cluster" {
    name = "fargate-cluster"
}

# Create an IAM role for ECS task execution with the necessary policies
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

# Define an ECS task for Fargate with specified resources and container settings
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
    subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

# Create an EventBridge rule to schedule the ECS task to run periodically
resource "aws_cloudwatch_event_rule" "ecs_task_scheduler" {
  name                = "ecs-task-scheduler"
  description         = "Schedule ECS task to run periodically"
  schedule_expression = "rate(1 hour)"  # Adjust the schedule as needed
}

# Create an EventBridge target to specify the ECS task to be run
resource "aws_cloudwatch_event_target" "ecs_task_target" {
  rule      = aws_cloudwatch_event_rule.ecs_task_scheduler.name
  arn       = aws_ecs_cluster.fargate_cluster.arn
  role_arn  = aws_iam_role.ecs_task_execution_role.arn
  ecs_target {
    task_definition_arn = aws_ecs_task_definition.fargate_task.arn
    task_count          = 1
    launch_type         = "FARGATE"
    network_configuration {
      subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
      security_groups = [aws_security_group.ecs_sg.id]
      assign_public_ip = true
    }
  }
}

# Allow EventBridge to invoke ECS tasks by attaching the necessary policy to the IAM role
resource "aws_iam_role_policy" "allow_eventbridge_to_invoke_ecs" {
  name   = "AllowEventBridgeToInvokeECS"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ecs:RunTask"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
      }
    ]
  })
}
