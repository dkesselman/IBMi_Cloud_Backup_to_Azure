        E='echo -e';e='echo -en';trap "R;exit" 2             
    AZCMD='blob-cmd'
 DFTACCNT='ewazblob001'
   DFTCNT='cntewazblob001'
  IFSPATH='/backup2cloud'      
   LIBLST=$IFSPATH'/liblist.lst'     
  FLISTHD='System-- Save Date/Time Object--- Type---- Attribute- Size (Bytes)---- Owner------ Description--------------' 
      ESC=$( $e "\e")
num_procs=3
   pgzthr=8
  maxsize=10
