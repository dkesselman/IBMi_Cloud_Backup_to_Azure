# IBM i Cloud Backup to AZURE BLOB Storage (Using Dialog)


How many times have I heard "How can I backup my IBM i / AS/400 to the cloud?". 
Today we have IBM Cloud Power Virtual Servers (Power VS) where you can create your LPAR with IBM i/AIX/Linux on Power , and the solution "by the book" is to use IBM Cloud Object Storage (ICOS) + BRMS + ICC . 
Unfortunately "IBM Cloud Storage Solutions for i" (5733-ICC) does not support Azure Cloud yet. 

On previous projects I published scripts to backup IBM i to "IBM Cloud Object Storage", "WASABI" and "OneDrive".

This IBM i PASE-BASH script uses NodeJS and "azure-storage-cmd" tool https://www.npmjs.com/package/azure-storage-cmd
I've also included dialog commmand (cdialog). You need to compile cdialog in order to use the script. Dialog brings a Linux-like look&feel to PASE.

# What can the script do?

* Creates a *SAVF for each library and SAVSECDTA when selecting "Save All Libraries"
* Compress *SAVF with 7zip
* Generates a CSV with *SAVF content for future references
* Allow to select the amount of simultaenous processes
* Uploads backup or individual files to your Azure BLOB container

![Cloud Menu](https://github.com/dkesselman/IBMi_Cloud_Backup_to_Azure/blob/main/IBMi_Backup_to_AZURE.gif "IBM i Backup to Azure - Menu")

# Pre-Reqs

* You need to install YUM on your systems, I recommmend using Access Client Solution, and then install this tools:

nodejs12
npm
readline
git
p7zip

* Set your PATH:

PATH=$PATH:/QOpenSys/pkgs/bin:/QOpenSys/pkgs/lib/nodejs/bin
export PATH

* Create a symbolic link for nodejs12 

ln -s /QOpenSys/pkgs/lib/nodejs12/bin/node  /usr/bin/node

* Your system needs to reach the Internet. 
* Setup SSH on your System (5733-SC1)
* You need a container in Azure Storage (Blobl). Try creating a free account https://azure.microsoft.com/
* You need to download the tool azure-storage-cmd    

npm install -g azure-storage-cmd

...and configure properly:

blob-cmd add-account <name> <key> [alias]

You need to download the .sh to some directory on your IFS, something like "/IBMiCloudBackup/" , change permissions with chmod +x *.sh 

Now you just need to adjust values in mnuaz_const.sh to reflect your configuration and run *mnuaz.sh* 
  
# ATTENTION: Don't use a trailing slash at the end of directions and PATHs !!!
  
When saving all libraries to Azure you can monitor backup using tail pointing to your log (from other SSH session):
  
  tail -f /backup2cloud/BAK20220206-095201.log
  
Please, submit your comments and questions to diego@esselware.com

NOTE:

I have found some issues with blob-cmd tool. Probably will switch to cURL on next release
