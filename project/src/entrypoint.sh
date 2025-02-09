#!/bin/bash
set -e

cmd="$@"

# Set default AWS region for SSM if not provided
if [ -z "$AWS_REGION_SSM" ]; then
  export AWS_REGION_SSM="us-west-2"
fi

# Fetch environment variables from SSM Parameter Store if enabled
if [ "$FETCH_SSM_PARAM_ENV" == "True" ]; then
  if [ -z "$SSM_PARAM_ENV_NAME" ]; then
    echo >&2 "SSM Parameter name not specified even after enabling its usage. Exiting the container."
    sleep 5
    exit 1
  else
    echo >&2 "Fetching the SSM Parameter from AWS."
    aws ssm get-parameter --with-decryption --name "$SSM_PARAM_ENV_NAME" --region "$AWS_REGION_SSM" | jq -r '.Parameter.Value' > /tmp/.env
    if [ $? -eq 0 ]; then
      export $(grep -v '^#' /tmp/.env | xargs -d '\n')
      rm /tmp/.env
    else
      echo >&2 "Unable to fetch the SSM Parameter. Exiting the container."
      sleep 5
      exit 1
    fi
  fi
fi

# Apply database migrations
echo >&2 "Applying database migrations..."
python manage.py migrate --noinput

# Collect static files
echo >&2 "Collecting static files..."
python manage.py collectstatic --noinput

# Start the application
if [ -z "$cmd" ]; then
  echo >&2 "Starting Django with Gunicorn..."
  gunicorn config.wsgi:application --bind 0.0.0.0:8000
else
  exec $cmd
fi
