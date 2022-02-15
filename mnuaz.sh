#/bin/bash

QIBM_MULTI_THREADED='Y'
export QIBM_MULTI_THREADED

source mnuaz_const.sh
source mnuaz_inc.sh

#***********************************************************************************#

EXIT="NO";

while [[ "$EXIT" == "NO" ]]; 
	resp=$(dialog --clear --title "BACKUP IBM i to AZURE - MENU" \
		--ok-label "Select" --cancel-label "Exit" --stdout \
        --menu "Select your option:" 20 51 9  \
        0  "List content on AZURE         " \
        1  "Upload file to  AZURE         " \
        2  "Get file from AZURE           " \
        3  "Delete file from AZURE        " \
        4  "Save Library to AZURE         " \
        5  "Save ALL Libraries to AZURE   " \
		6  "List library saved on AZURE   " \
		7  "ABOUT                         " )
## dialog --title "Selection" --msgbox $resp 0 0;
	do case $resp in
        0) BUCKETLS ;;
        1) BUCKETPT ;;
        2) BUCKETGT ;;
        3) BUCKETDL ;;
        4) BKPTOCLD ;;
        5) BKPTOCLD2;;
        6) LSTCLDBKP;;
        7) dialog --title "ABOUT THIS SOFTWARE" --msgbox "\n       IBM i Backup to AZURE BLOB Menu\n\n\n         by ESSELWARE SOLUCIONES" 10 50 ;;
	esac;
done
clear
exit 0
