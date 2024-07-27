#!/bin/bash
echo "7z archive creation started...."
# Load configuration variables
source ./config.sh

# Change to the parent directory of the current script
cd ..

echo "Current directory: $(pwd)"

# Convert the Windows path to a Git Bash compatible path
SEVEN_ZIP_PATH="/c/Program Files/7-Zip/7z.exe"

# Create an archive of the Rewatch folder
"$SEVEN_ZIP_PATH" a "Rewatch/Rewatch_$REWATCH_VERSION.zip" "Rewatch/*.lua" "Rewatch/*.toc" "Rewatch/assets" "Rewatch/src"

# Change back to the Rewatch directory
cd $REWATCH_SOURCE

echo "7z archive creation complete."