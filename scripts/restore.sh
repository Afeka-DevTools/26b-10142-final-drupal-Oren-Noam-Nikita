#!/bin/bash

# Load global variables
source "$(dirname "${BASH_SOURCE[0]}")/load_env.sh"

echo "Searching for Drupal backups..."

# Find the newest Drupal backup file (If exists)
LATEST_DRUPAL_BACKUP=$(ls -t $DRUPAL_BACKUP_DIR/drupal_backup_*.tar.gz 2>/dev/null | head -n 1)

# Check if Drupal backup was found
if [ -z "$LATEST_DRUPAL_BACKUP" ]; then
    echo "Error: No Drupal backups found!"
    exit 1
fi

echo "Drupal backup found"
echo "Searching for matching database backup..."

# Get drupal backups file basename (Without file extension)
DRUPAL_BACKUP_FILENAME=$(basename "$LATEST_DRUPAL_BACKUP")

# Extract timestamp
TIMESTAMP=$(echo "$DRUPAL_BACKUP_FILENAME" | grep -oE '[0-9]{8}_[0-9]{6}')

DB_BACKUP_FILENAME="db_backup_${TIMESTAMP}.sql"

# Reconstruct matching DB dump file path
LATEST_DB_BACKUP="$DB_BACKUP_DIR/$DB_BACKUP_FILENAME"

# Check if the exact matching pair exists
if [ ! -f "$LATEST_DB_BACKUP" ]; then
    echo "Error: Backup mismatch! Found Drupal files but no matching database backup"
    exit 1
fi

echo "Database backup found"
echo "Restoring backups..."

echo "Restoring Drupal backup: $LATEST_DRUPAL_BACKUP"
tar -xzf "$LATEST_DRUPAL_BACKUP" -C ./ >/dev/null 2>&1

echo "Restoring Database backup: $LATEST_DB_BACKUP"
cat "$LATEST_DB_BACKUP" | docker compose exec -T postgres psql -U ${DATABASE_USER} -d ${DATABASE_NAME} --quiet &>/dev/null

echo "Backups restored successfully!"
