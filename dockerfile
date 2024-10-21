# Use official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script into the container
COPY factorial.py .

# Set the default command to run the Python script
CMD ["python", "factorial.py", "5"]
