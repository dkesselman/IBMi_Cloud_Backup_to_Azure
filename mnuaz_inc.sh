#***********************************************************************************# 
#                           Cloud Functions                                         # 
#***********************************************************************************# 

BUCKETLS(){ 
          azpath=$(dialog --title "Backup IBM i to Azure - List" --stdout  \
          --inputbox "AZURE Container:" 0 0) ;
          retval=$? 
          case $retval in
           ${DIALOG_OK-0}) 
             response=$($AZCMD ls $azpath) 
             dialog --title  "Backup IBM i to Azure - List" \
                    --msgbox "$response" 20 70 ;;
           ${DIALOG_CANCEL-1}) echo "Cancel pressed.";;
           ${DIALOG_ESC-255}) echo "Esc pressed.";;
           ${DIALOG_ERROR-255}) echo "Dialog error";;
           *) echo "Unknown error $retval";;
          esac 

          };
BUCKETDL(){
          azobject=$(dialog --title "Backup IBM i to Azure - Delete" \
          --stdout  --inputbox "AZURE Source  File:" 0 0);
          retval=$?
          case $retval in
           ${DIALOG_OK-0})
             response=$($AZCMD -v rm $azobject); 
             dialog  --title  "Backup IBM i to Azure - Delete"  \ 
                     --msgbox  "Deleting $azobject -$response" 8 70 ;;
           ${DIALOG_CANCEL-1}) echo "Cancel pressed.";;
           ${DIALOG_ESC-255}) echo "Esc pressed.";;
           ${DIALOG_ERROR-255}) echo "Dialog error" ;;
           *) echo "Unknown error $retval";;
          esac          
          };

BUCKETPT(){ 
          response=$(dialog --title "Backup IBM i to Azure - Upload" \
          --form  "Fill Information" 0 0 0 \
          "AZURE Container:" 1 1 "$azpath" 1 20 20 80 \
          "IFS PATH to File:" 2 1 "$ifsfile" 2 20 20 80 \
          3>&1 1>&2 2>&3 3>&- )
          retval=$? 
          case $retval in
           ${DIALOG_OK-0})
             resp=($response)
             azpath=${resp[0]}
             ifsfile=${resp[1]}
             $AZCMD -v cp $ifsfile $azpath ;;
           ${DIALOG_CANCEL-1}) echo "Cancel pressed.";;
           ${DIALOG_ESC-255}) echo "Esc pressed.";;
           ${DIALOG_ERROR-255}) echo "Dialog error" ;;
           *) echo "Unknown error $retval";;
          esac          
          };

BUCKETGT(){
          response=$(dialog --title "Backup IBM i to Azure - Download" \
          --form  "Fill Information" 0 0 0 "AZURE Source File:" 1 1 \
          "$azobject" 1 20 20 80 "IFS PATH to File:" 2 1 "$ifsfile" \
          2 20 20 80\
          3>&1 1>&2 2>&3 3>&- )
          retval=$? 
          case $retval in
           ${DIALOG_OK-0}) 
             resp=($response);
             azobject=${resp[0]}
             ifsfile=${resp[1]}
             $AZCMD -v cp $azobject $ifsfile ;;
           ${DIALOG_CANCEL-1}) echo "Cancel pressed.";;
           ${DIALOG_ESC-255}) echo "Esc pressed.";;
           ${DIALOG_ERROR-255}) echo "Dialog error";;
           *) echo "Unknown error $retval";;
          esac 
          };

 ASKLIB1(){ 
          libname="";
          azpath="";
          response=$(dialog --title "Backup IBM i to Azure - Backup Library" \
          --form "Fill Information" 0 0 0 \
          "Library Name:    " 1 1 "$libname" 1 20 20 80 \
          "AZURE Container: " 2 1 "$azpath"  2 20 20 80 \
          3>&1 1>&2 2>&3 3>&- ); 
		  retval=$? 
          case $retval in
           ${DIALOG_OK-0}) 
             resp=($response);
			 libname=${resp[0]};
			 azpath=${resp[1]};
			 ifsfile=$IFSPATH/$libname.7z ;
			 $AZCMD -v cp $azobject $ifsfile ;;
           ${DIALOG_CANCEL-1}) echo "Cancel pressed.";;
           ${DIALOG_ESC-255}) echo "Esc pressed.";;
           ${DIALOG_ERROR-255}) echo "Dialog error";;
           *) echo "Unknown error $retval"
          esac 
		  };


 SAVLIST(){ 
          listfile=$IFSPATH'/'$libname'_lst';
          system "CPYTOIMPF FROMFILE(BACKUPSAV/BKPLOG $libname)  \
            TOSTMF('$listfile') MBROPT(*ADD)  STMFCCSID(1208)    \ 
            RCDDLM(*CRLF) DTAFMT(*DLM) DATFMT(*YYMD)" ;}; 
 CRTLIB1(){ [ -d $IFSPATH ] && mkdir -p $IFSPATH; system "CRTLIB BACKUPSAV" 2>&1 ;  }         
     B2C(){ $AZCMD -v cp $ifsfile $azobject ;$AZCMD -v cp $ifslog $azlog;}              
BKPTOCLD(){
			ASKLIB1;
			if [$libname != ""]; then 
				CRTLIB1;
				SAVLIB1;
				SAVLIST;
				ZIPLIB1; 
				B2C;
			fi
			}         
SAVZIP2(){ $E 'Saving Library:' $libname ' - ' $dt;SAVLIB1;SAVLIST;ZIPLIB1;B2C;}
 UNZIP1(){ 7z e -y $libname"_lst.7z" ; }
#***********************************************************************************#        
LSTCLDBKP(){
ASKLIB1;
if [$libname != ""]; then 

	cd $IFSPATH

	azobject=$azpath"/"$libname"_lst.7z";
	ifsobject=$IFSPATH"/"$libname"_lst.7z";
	echo $azobject  ;
	$AZCMD -v cp $azobject $ifsobject ; 
	UNZIP1;
	#------------------------------------------
	CLEAR;WRITE;MARK;TPUT 6 0 
	$E $FLISTHD; 
	awk -F "," '{print($3,$12,$13,$15,$16,$17,$18,$22)}' $libname"_lst" | tr -d '"';
	#------------------------------------------
fi
}
#***********************************************************************************#                                                                                                                                                     
SAVLIB1(){ 

azobject=$azpath"/"$libname".7z" ;
azlog=$azpath"/"$libname"_lst.7z" ;

if [ -f $IFSPATH"/"$libname".7z*" ]; then
    rm $IFSPATH"/"$libname".7z*" 2>&1
    rm $IFSPATH"/"$libname"_lst.7z*" 2>&1
fi

if [ -f "/QSYS.LIB/BACKUPSAV.LIB/"$libname".FILE" ]; then
    rm /QSYS.LIB/BACKUPSAV.LIB/$libname.FILE  2>&1 ;
fi

system "RMVM FILE(BACKUPSAV/BKPLOG) MBR($libname)" 2>&1;
system "CRTSAVF BACKUPSAV/$libname"; 
system "SAVLIB LIB($libname) DEV(*SAVF) SAVF(BACKUPSAV/$libname) SAVACT(*LIB) SAVACTWAIT(60) OUTPUT(*OUTFILE) OUTFILE(BACKUPSAV/BKPLOG) OUTMBR($libname)"; 
}
#**********************************************************************************#        
 ZIPLIB1(){

cd /QSYS.LIB/BACKUPSAV.LIB/;
if [ -f $IFSPATH"/"$libname".7z*" ]; then
    rm $IFSPATH"/"$libname".7z*" 2>&1 ; 
fi

$e "Compressing: " $libname ;

# Check file size in GB 
##fsize=$(du --apparent-size --block-size=1073741824  $libname".FILE" | awk '{ print $1}');
##$e "Size: "$fsize"GB";
cd $IFSPATH;
##if [ $fsize -gt $maxsize ]; then
##	maxsizeb=$maxsize * 1073741824;
##        cat "/QSYS.LIB/BACKUPSAV.LIB/"$libname".FILE" | 7z a -v${maxsize}g -mx1 -mmt${pgzthr} -si $libname".7z";
##else 
	cat "/QSYS.LIB/BACKUPSAV.LIB/"$libname".FILE" |7z a -mx1 -mmt${pgzthr} -si $libname".7z";
##fi

if [ -f $libname".FILE" ]; then
    rm $libname".FILE" 2>&1 ;
fi

ifslog=$IFSPATH"/"$libname"_lst.7z";
cd $IFSPATH; 
cat $IFSPATH"/"$libname"_lst"| 7z a -mx1 -si $ifslog;

if [ -f $libname"_lst" ]; then
    rm $libname"_lst" 2>&1 ;
fi

}  
#***********************************************************************************#        
SAVSECDTA(){

if [ -f /QSYS.LIB/BACKUPSAV.LIB/SAVSECDTA.FILE ]; then
    rm /QSYS.LIB/BACKUPSAV.LIB/SAVSECDTA.FILE 2>&1 ;
fi
system "CRTSAVF BACKUPSAV/SAVSECDTA"; 
system "SAVSECDTA DEV(*SAVF) SAVF(BACKUPSAV/SAVSECDTA) OUTPUT(*OUTFILE) OUTFILE(BACKUPSAV/BKPLOG) OUTMBR(SAVSECDTA)"; 
libname="SAVSECDTA";
ifsfile=$IFSPATH"/"$libname".7z";
azobject=$azpath"/"$libname".7z" ;
azlog=$azpath"/"$libname"_lst.7z" ;
SAVLIST;
ZIPLIB1;
B2C; 
}   
#***********************************************************************************#                                                                                                                                                     
BKPTOCLD2(){
CRTLIB1;

dt=$(date '+%Y%m%d-%H%M%S');
dt2=$(date '+%Y%m%d');

azpath='blob://'$DFTACCNT'/'$DFTCNT'/BKP'$dt2'/';

#Purge BACKUPSAV library and IFS path
rm /QSYS.LIB/BACKUPSAV.LIB/*.FILE 2>&1
rm $IFSPATH"/*.7z*" 2>&1
rm $IFSPATH"/*_lst" 2>&1

#List libraries excluding Q*, SYS* & ASN
cd /QSYS.LIB;ls |grep '\.LIB' |cut -f1 -d"." |grep -Fv -e 'Q' -e 'SYS' -e '#' -e 'ASN' -e 'BACKUPSAV'  > $LIBLST;

#Add some libraries to the list
$E "QGPL"    >> $LIBLST;    
$E "QS36F"   >> $LIBLST;    
$E "QUSRSYS" >> $LIBLST;    

LOGNAME=$IFSPATH"/BAK"$dt".log";                                                                                                                                                      
$E 'SAVING DATA TO :' $azpath

$E 'Starting Backup: BKP' $dt2 ' - ' $dt > $LOGNAME    

# Save Security Data
$E 'Saving Security Data: ' $azpath  >> $LOGNAME    
 
SAVSECDTA;                 

# Save library 1 by 1
i=0;
num_jobs="\j"
liblst=$(cat $LIBLST);
for libname in $liblst
do
        i=$((i+1));
        ifsfile=$IFSPATH"/"$libname".7z" ;
	azobject=$azpath"/"$libname".7z" ;
	azlog=$azpath"/"$libname"_lst.7z" ;
        dt=$(date '+%Y%m%d-%H%M%S');
	SAVZIP2 >> $LOGNAME & 
        while (( ${num_jobs@P} >= num_procs )) 
        do
            wait -n
        done
done

wait


$e $i "Libraries backed up to " $azpath;
 
dt=$(date '+%Y%m%d-%H%M%S');
echo 'Backup ending: BKP' $dt2 ' - ' $dt > $LOGNAME                                                                                                                                                                                     
} 
#***********************************************************************************#                             
  
