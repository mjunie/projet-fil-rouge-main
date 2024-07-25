
  # Use the official Python 3.6-alpine image from the Docker Hub
FROM python:3.6-alpine
MAINTAINER junie (juniemacougoum@gmail.com)

RUN mkdir /data

# Set the working directory in the container
WORKDIR /opt

# Copy the requirements file into the container
COPY requirements.txt .

# Install system dependencies and create a working directory
RUN apk update && apk add --no-cache gcc musl-dev libffi-dev

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

ENV ODOO_URL="http://localhost:8069/web/database/selector" \
    PGADMIN_URL="http://localhost:8081/login?next=/"

# EXPOSE 8080
# Define a volume for persistent storage
VOLUME /data
# Specify the command to run the application
CMD ["python", "app.py"]

