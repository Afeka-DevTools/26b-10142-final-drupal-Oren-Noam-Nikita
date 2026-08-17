#!/bin/bash

# Load global variables
source "$(dirname "${BASH_SOURCE[0]}")/load_env.sh"

# Creating backup file names with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DRUPAL_BACKUP_FILE="$DRUPAL_BACKUP_DIR/drupal_backup_${TIMESTAMP}.tar.gz"
DB_BACKUP_FILE="$DB_BACKUP_DIR/db_backup_${TIMESTAMP}.sql"

# Database Backup
echo "Creating database backup..."
docker compose exec -T postgres pg_dump -U "$DATABASE_USER" --clean --if-exists "$DATABASE_NAME" > "$DB_BACKUP_FILE"

# Verify the pg_dump command succeeded
if [ $? -ne 0 ]; then
    echo "Error: Database backup failed!"

    # Delete the empty / corrupted backup file and exit
    rm -f "$DB_BACKUP_FILE"
    exit 1
fi

echo "Database backup was successful"

# Drupal Backup
echo "Creating drupal backup..."

# Compress Drupal data for backup
tar -czf "$DRUPAL_BACKUP_FILE" "$DRUPAL_DATA_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Drupal backup failed!"

    # Delete the empty / corrupted backup file and exit
    rm -f "$DRUPAL_BACKUP_FILE"
    exit 1
fi

echo "Drupal backup was successful"
echo

echo "Files backed up successfully!"
echo "Database backup saved to: $DB_BACKUP_DIR"
echo "Drupal backup saved successfully at: $DRUPAL_BACKUP_DIR"
