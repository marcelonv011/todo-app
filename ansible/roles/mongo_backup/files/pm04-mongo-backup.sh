#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

BACKUP_DIR="/var/backups/pm04-mongodb"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$BACKUP_DIR"

TEMP_FILE="$(mktemp "$BACKUP_DIR/.backup.XXXXXXXX")"
FINAL_FILE="$BACKUP_DIR/todo-app-$TIMESTAMP.archive.gz"

trap 'rm -f "$TEMP_FILE"' EXIT

docker exec todo-mongo sh -eu -c '
  umask 077
  CONF=$(mktemp)
  trap "rm -f \"$CONF\"" EXIT

  printf "password: \"%s\"\n" "$MONGO_APP_PASSWORD" > "$CONF"

  mongodump \
    --host 127.0.0.1 \
    --username "$MONGO_APP_USERNAME" \
    --authenticationDatabase todo-app \
    --config "$CONF" \
    --db todo-app \
    --archive \
    --gzip
' > "$TEMP_FILE"

test -s "$TEMP_FILE"
gzip -t "$TEMP_FILE"

mv "$TEMP_FILE" "$FINAL_FILE"
# Subir backup a Azure Blob Storage usando la identidad administrada
BLOB_URL="https://pm04bk504520.blob.core.windows.net/mongodb-backups/$(basename "$FINAL_FILE")"

echo "Subiendo backup a Azure Blob Storage..."

AZCOPY_AUTO_LOGIN_TYPE=MSI azcopy copy \
  "$FINAL_FILE" \
  "$BLOB_URL" \
  --overwrite=false

echo "PM04_BACKUP_CLOUD_OK $(basename "$FINAL_FILE")"

# Retener siete dias de backups locales.
find "$BACKUP_DIR" -maxdepth 1 -type f \
  -name 'todo-app-*.archive.gz' -mtime +7 -delete

echo "PM04_BACKUP_OK $(basename "$FINAL_FILE")"
