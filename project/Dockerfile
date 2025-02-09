FROM python:3.13
LABEL maintainer="Kush enterprise kushkakuamr@gmail.com"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
ENV APP_HOME=/application/project
ENV PYTHONUNBUFFERED=1

# Define en_US locale
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LC_MESSAGES=en_US.UTF-8

# Set the working directory
WORKDIR $APP_HOME

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    gcc \
    libpq-dev \
    python3-dev \
    python3-psycopg2 \
    vim \
    curl \
    unzip \
    jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Create a non-root user and group
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

# Copy application files and directories
COPY apps/ $APP_HOME/apps
COPY config/ $APP_HOME/config
COPY manage.py $APP_HOME/manage.py
COPY requirements.txt $APP_HOME/requirements.txt
COPY src/entrypoint.sh $APP_HOME/entrypoint.sh

# Ensure directories exist and have correct permissions
RUN mkdir -p $APP_HOME/staticfiles && \
    mkdir -p $APP_HOME/static && \
    chown -R appuser:appuser $APP_HOME && \
    chmod -R 755 $APP_HOME

# Make the entrypoint script executable
RUN chmod +x $APP_HOME/entrypoint.sh

# Switch to the non-root user
USER appuser
ENV PATH="/home/appuser/.local/bin:$PATH"

# Install Python dependencies
RUN python -m pip install --no-cache-dir -r requirements.txt

# Expose port 8000 for the app
EXPOSE 8000

# Default entrypoint command to run the Flask app
ENTRYPOINT ["src/entrypoint.sh"]

