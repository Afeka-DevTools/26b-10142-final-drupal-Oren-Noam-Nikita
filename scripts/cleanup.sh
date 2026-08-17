#!/bin/bash

# Global variables not needed

# Backup data before cleanup
echo "Performing backup before shutdown"
bash scripts/backup.sh

echo "Initiating cleanup..."
# Remove all Docker projected-related data - Containers, Images, Networks, Volumes
docker compose down -v --rmi all

echo "Deleting all project data..."
sudo rm -rf data/

echo "Cleanup finished successfully"
