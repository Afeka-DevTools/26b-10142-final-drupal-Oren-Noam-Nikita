#!/bin/bash

# Validate that Docker is installed properly
echo "Checking if Docker is installed..."

# Verify Docker Engine is installed
if ! command -v docker > /dev/null 2>&1; then
    echo "Error: Docker is not installed! Please make sure Docker is installed and try again"
    exit 1
fi

# Verify Docker Compose is installed (As standalone / Plugin)
if ! docker compose version > /dev/null 2>&1 && ! command -v docker-compose > /dev/null 2>&1; then
    echo "Error: Docker Compose is not installed! Please make sure Docker Compose is installed and try again"
    exit 1
fi

echo "Docker is installed"

# Load global variables
source "$(dirname "${BASH_SOURCE[0]}")/load_env.sh"

# Creating data directories (If doesn't exist)
echo "Validating data directories..."

mkdir -p \
$DRUPAL_DATA_DIR/sites \
$DRUPAL_DATA_DIR/modules \
$DRUPAL_DATA_DIR/profiles \
$DRUPAL_DATA_DIR/themes \
$DRUPAL_BACKUP_DIR \
$DB_BACKUP_DIR

echo "Data directories validated"

if [ -z "$(ls -A "$DRUPAL_DATA_DIR/sites")" ]; then
    echo "Initializing default Drupal files..."
    docker run --rm -v "$(pwd)/$DRUPAL_DATA_DIR:/tmp/data" drupal:latest cp -r /opt/drupal/web/sites/. /tmp/data/sites/
    echo "Files initialized"
fi

# Drupal must have ownership / permissions over the data directory 
# If drupal is denied access, the website will fail with error 403 (Forbidden)
echo "Setting Drupal permissions..."
sudo chown -R 33:33 "$DRUPAL_DATA_DIR"
sudo chmod -R 775 "$DRUPAL_DATA_DIR"

# Initiate docker environment
echo "Booting up the environment..."
docker compose up -d

echo "Waiting 10 seconds for databases to initialize..."
sleep 10

echo "Searching for backups..."
if ! bash scripts/restore.sh; then
    echo "Backup aborted, proceeding clean install."
fi

# Success message
echo "Done! Drupal was created on the endpoint - http://localhost:8080"
echo "Give Drupal a minute to boot up before opening"