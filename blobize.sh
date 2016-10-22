#!/bin/sh

# Path to curl binary
CURL_BIN=curl

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














urlencode_grouped_case () {
  string=$1; format=; set --
  while
    literal=${string%%[!-._~0-9A-Za-z]*}
    case "$literal" in
      ?*)
        format=$format%s
        set -- "$@" "$literal"
        string=${string#$literal};;
    esac
    case "$string" in
      "") false;;
    esac
  do
    tail=${string#?}
    head=${string%$tail}
    format=$format%%%02x
    set -- "$@" "'$head"
    string=$tail
  done
  printf "$format\\n" "$@"
}

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
	MIME_TYPE=$(file -b --mime-type $FILE_PATH)

	AVAILABLE=$(( FILE_COUNTER % SIMULTANEOUS_UPLOADS ))
	if [ $AVAILABLE -eq 0 ]; then
		wait
	fi

	echo "FILENUMBER: $FILE_COUNTER BLOB_NAME: $BLOB_NAME" >> $AZURE_CLI_LOG

	BLOB_NAME_URL=$(urlencode_grouped_case $BLOB_NAME)
	DATE_UTC=$(date -u)
	$CURL_BIN -X PUT -T $FILE_PATH -H "x-ms-date: $DATE_UTC" -H "Content-Type: $MIME_TYPE" -H "x-ms-blob-type: BlockBlob" \
		--silent --write-out "%{http_code} :$FILE_PATH\n" \
		"https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$BLOB_CONTAINER/$BLOB_NAME_URL$SAS_TOKEN" >> $AZURE_CLI_LOG 2>>$AZURE_CLI_ERRORLOG &

	BLOB_NAME_URL=
done
set +f
IFS="$OIFS"
