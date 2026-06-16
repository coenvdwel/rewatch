#!/bin/bash

# Load configuration variables
source ./config.sh

# Display the current operation
echo "Setting up paths and version number..."
echo "WOW AddOn Folder: $WOW_ADDON_FOLDER"
echo "Rewatch Version: $REWATCH_VERSION"
echo "7-Zip Path: $SEVEN_ZIP_PATH"

# Call the 7z.sh script
echo "Running 7z.sh to create the archive..."
./7z.sh

# Check if 7z.sh executed successfully
if [ $? -eq 0 ]; then
    echo "7z.sh executed successfully."
else
    echo "Error: 7z.sh failed."
    exit 1
fi

# Clean existing files in the WoW AddOn folder
echo "Cleaning existing files in the WoW AddOn folder..."
rm -rfv "$WOW_ADDON_FOLDER/Rewatch"
echo "Clean up complete."

# Change to the WoW AddOn folder
#echo "Changing to the WoW AddOn folder..."
#cd "$WOW_ADDON_FOLDER"
#echo "Current directory: $(pwd)"

# Deploy the Rewatch AddOn by extracting the zip file to the AddOn folder
echo "Extracting Rewatch AddOn version $REWATCH_VERSION..."
"$SEVEN_ZIP_PATH" x "$REWATCH_SOURCE/Rewatch_$REWATCH_VERSION.zip" -o"$WOW_ADDON_FOLDER" -y
echo "Extraction complete."

# Wait for user input before closing
echo "Deployment finished. Press Enter to exit..."
read -p ""