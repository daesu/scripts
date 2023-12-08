#!/bin/bash

# Enable debugging
set -x

# Load the .env file
if [ -f ".env" ]; then
    source ".env" > /dev/null 2>&1
else
    echo "Error: .env file not found."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"

# Create the backups directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backups directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi


# Create a timestamp
TIMESTAMP=$(date +"%Y%m%d")

# Archive the directory and store in the backups directory
ARCHIVE_NAME="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
ENCRYPTED_ARCHIVE_NAME="$ARCHIVE_NAME.cpt"

# List files in the remote directory and search for the specific file
if rclone lsf $REMOTE_NAME:$REMOTE_PATH | grep -q ${ENCRYPTED_ARCHIVE_NAME##*/}; then
    echo "File exists: ${ENCRYPTED_ARCHIVE_NAME##*/}"
    exit 0
fi

echo "Archiving directory: $DIRECTORY_TO_ARCHIVE"
echo "Creating archive: $ARCHIVE_NAME"
tar -czvf "$ARCHIVE_NAME" -C "$DIRECTORY_TO_ARCHIVE" .

# Check if the archive was created successfully
if [ -f "$ARCHIVE_NAME" ]; then
    echo "Archive created successfully."
else
    echo "Failed to create archive."
    exit 1
fi

# Encrypt the archive with ccencrypt using passphrase from environment variable
echo "Encrypting the archive: $ENCRYPTED_ARCHIVE_NAME"
ccencrypt -f -K "$CCENCRYPT_PASS" $ARCHIVE_NAME > /dev/null 2>&1

# Check if the encryption was successful
if [ -f $ENCRYPTED_ARCHIVE_NAME ]; then
    echo "Encryption successful."
else
    echo "Failed to encrypt the file."
    exit 1
fi

# Rclone the encrypted archive to the remote
echo "Uploading encrypted archive to remote: $REMOTE_NAME"
rclone copy $ENCRYPTED_ARCHIVE_NAME $REMOTE_NAME:$REMOTE_PATH

# Delete the local archive
echo "Deleting local archive."
rm $ARCHIVE_NAME

# Delete the local encrypted archive
echo "Deleting local encrypted archive."
rm $ENCRYPTED_ARCHIVE_NAME

# Delete remote encrypted archives older than 30 days
echo "Deleting remote encrypted archives older than 30 days."
rclone delete $REMOTE_NAME:notes/backup/ --min-age 10d

echo "Backup process completed."

