README
======

What is blobize.sh?
-------------------

blobize.sh is a shell script that uploads the entire contents of a folder to 
Azure Blob Storage.


Requirements
------------
- Linux/Unix system
- Azure CLI

To use blobize.sh you need to have the Azure Command-Line Interface 
(Azure CLI) installed.
Instructions for installing the Azure CLI can be found [here](https://azure.microsoft.com/nl-nl/documentation/articles/xplat-cli-install/).


Using blobize.sh
----------------

To use blobize.sh you need to set your Azure storage account name, 
container name and SAS token. These can be configured by updating 
the first few lines of this script:
    
    # Shared Access Signature, get it from the Azure Portal, starts with '?sv=', not the full URL.
    SAS_TOKEN='enter_sas_token_here'
    
    # Storage Account Name
    AZURE_STORAGE_ACCOUNT='enter_storage_account_name_here'
    
    # container name, must be created already in the Azure portal before running this script
    BLOB_CONTAINER='enter_container_name_here'
    
Then upload the entire contents of a folder (inlcuding its subfolders) to Azure Blob Storage:

    $ blobize.sh <folder>

Example:

You have this directory structure:
	
	/var/www/application/files/
	/var/www/application/files/invoices
	/var/www/application/files/orders
	/var/www/application/files/attachments


If you want to upload everything in ```/var/www/application/files``` to an Azure Blob Container run:

    $ blobize.sh /var/www/application/files


Configuration reference
----------------------

You can edit the first few lines in blobize.sh:

    # Path to Azure CLI binary
    AZURE_CLI_BIN=azure
    
    # Path to log file for this script
    AZURE_CLI_LOG=upload.log
    
    # Path to error log file for this script
    AZURE_CLI_ERRORLOG=error.log
    
    # If the script gets interupted, you can check the log file for the last successful FILENUMBER,
    # Enter that number here to continue from there.
    START_FROM=0
    
    # Number of simultaneous uploads, increase to upload faster.
    SIMULTANEOUS_UPLOADS=8
    
    # Shared Access Signature, get it from the Azure Portal, starts with '?sv=', not the full URL.
    SAS_TOKEN='enter_sas_token_here'
    
    # Storage Account Name
    AZURE_STORAGE_ACCOUNT='enter_storage_account_name_here'
    
    # container name, must be created already in the Azure portal
    BLOB_CONTAINER='enter_container_name_here'
    
    # Only upload files that match this pattern, for example:
    # '*.pdf' to upload only pdf files
    # Default is '*' for any file
    FILENAME_PATTERN='*'