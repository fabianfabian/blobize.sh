#!/bin/sh

# Path to Azure CLI binary
AZURE_CLI_BIN=azure

# Path to log file for this script
AZURE_CLI_LOG=blobize_upload.log

# Path to error log file for this script
AZURE_CLI_ERRORLOG=blobize_error.log

# If the script gets interupted, you can check the log file for the last succesfull FILENUMBER,
# Enter the the number here to continue 
START_FROM=0

# Number of simultaneous uploads. Increase to upload faster.
SIMULTANEOUS_UPLOADS=8

# Shared Access Signature, get it from the Azure Portal, starts with '?sv=', not the full URL.
SAS_TOKEN='enter_sas_token_here'

# Storage Account Name
AZURE_STORAGE_ACCOUNT='enter_storage_account_name_here'

# #container name, must be created already in the Azure portal
BLOB_CONTAINER='enter_container_name_here'

# # Only upload files that match this pattern, for example:
# # '*.pdf' to upload only pdf files
# # Default is '*' for any file
FILENAME_PATTERN='*'






















FOLDER=$1
cd $FOLDER

FILE_COUNTER=0

OIFS="$IFS"
IFS=$'\n'
set -f
for FILE_PATH in `find . -type f -name $FILENAME_PATTERN`  
do
	FILE_COUNTER=$((FILE_COUNTER+1))
	if [ $FILE_COUNTER -lt $START_FROM ]; then
		continue
	fi
	BLOB_NAME=$(echo $FILE_PATH | cut -c 3-)
	

	AVAILABLE=$(( FILE_COUNTER % SIMULTANEOUS_UPLOADS ))
	if [ $AVAILABLE -eq 0 ]; then
		wait
	fi

	echo "FILENUMBER: $FILE_COUNTER BLOB_NAME: $BLOB_NAME" >> $AZURE_CLI_LOG
	$AZURE_CLI_BIN storage blob upload --quiet "$FILE_PATH" $BLOB_CONTAINER "$BLOB_NAME" --sas $SAS_TOKEN --account-name $AZURE_STORAGE_ACCOUNT >> $AZURE_CLI_LOG 2>>$AZURE_CLI_ERRORLOG &    
done
set +f
IFS="$OIFS"
