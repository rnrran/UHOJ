#!/bin/bash
# Script untuk backup aplikasi OnlineJudge
# Usage: ./backup.sh [backup_directory]

BACKUP_DIR=${1:-./backups}
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="onlinejudge-backup-$DATE.tar.gz"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

echo "=========================================="
echo "OnlineJudge Backup Script"
echo "=========================================="
echo ""
echo "Backup directory: $BACKUP_DIR"
echo "Backup file: $BACKUP_FILE"
echo ""

# Check if docker-compose is running
if docker-compose ps | grep -q "Up"; then
    echo "⚠️  Warning: Containers are still running!"
    echo "   It's recommended to stop containers first for data consistency."
    read -p "   Stop containers now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping containers..."
        docker-compose down
    else
        echo "Continuing with backup while containers are running..."
        echo "   (Data might not be fully consistent)"
    fi
fi

echo ""
echo "Creating backup..."

# Backup essential files
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
  data/ \
  docker-compose.yml \
  logo.png \
  2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created successfully!"
    echo "   File: $BACKUP_DIR/$BACKUP_FILE"
    echo "   Size: $BACKUP_SIZE"
    echo ""
    echo "To restore on another machine:"
    echo "   1. Extract: tar -xzf $BACKUP_FILE"
    echo "   2. Start: docker-compose up -d --build"
else
    echo "❌ Backup failed!"
    exit 1
fi

# If containers were stopped, ask to start again
if ! docker-compose ps | grep -q "Up"; then
    read -p "Start containers again? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting containers..."
        docker-compose up -d
    fi
fi

echo ""
echo "Backup completed!"

