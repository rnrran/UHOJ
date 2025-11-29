#!/bin/bash
# Script untuk restore aplikasi OnlineJudge dari backup
# Usage: ./restore.sh <backup_file.tar.gz>

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    echo ""
    echo "Example:"
    echo "  $0 backups/onlinejudge-backup-20241129_120000.tar.gz"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo "OnlineJudge Restore Script"
echo "=========================================="
echo ""
echo "Backup file: $BACKUP_FILE"
echo ""

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    echo "⚠️  Warning: Containers are running!"
    read -p "   Stop containers before restore? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping containers..."
        docker-compose down
    else
        echo "❌ Cannot restore while containers are running!"
        exit 1
    fi
fi

echo ""
echo "Extracting backup..."

# Extract backup
tar -xzf "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup extracted successfully!"
    echo ""
    
    # Check if essential files exist
    if [ ! -d "data" ]; then
        echo "❌ Error: data/ directory not found in backup!"
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ Error: docker-compose.yml not found in backup!"
        exit 1
    fi
    
    echo "Verifying backup contents..."
    echo "  ✓ data/ directory found"
    echo "  ✓ docker-compose.yml found"
    
    if [ -d "data/postgres" ]; then
        echo "  ✓ Database data found"
    else
        echo "  ⚠️  Warning: Database data not found (will start with empty database)"
    fi
    
    echo ""
    read -p "Start application now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting application..."
        docker-compose up -d --build
        
        echo ""
        echo "✅ Application started!"
        echo ""
        echo "Waiting for containers to be ready..."
        sleep 5
        
        echo ""
        echo "Container status:"
        docker-compose ps
        
        echo ""
        echo "To check logs:"
        echo "  docker-compose logs -f"
    else
        echo ""
        echo "To start application manually:"
        echo "  docker-compose up -d --build"
    fi
else
    echo "❌ Extract failed!"
    exit 1
fi

echo ""
echo "Restore completed!"

