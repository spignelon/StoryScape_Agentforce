FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    redis-server \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Install VirtualEnv
RUN pip install --no-cache-dir virtualenv

# Copy project files
COPY . .

# Create virtual environment
RUN virtualenv venv

# Activate virtual environment and install requirements
RUN . venv/bin/activate && pip install --no-cache-dir -r requirements.txt

# Expose the port your app runs on
EXPOSE 8000

# Start Redis server
RUN systemctl enable redis-server

# Default command to run app and Celery
CMD ["sh", "-c", "redis-server & \ 
    . venv/bin/activate && \ 
    python3 app.py & \ 
    celery -A app.celery worker --loglevel=info"]
