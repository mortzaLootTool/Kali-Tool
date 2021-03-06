#!/bin/bash
start_hostname_changer()
{
if [[ "$hostname_changer_status" == "Disable" ]]; 

#backup hostname and change
cat /etc/hostname > $BACKUPIR/hostname.bak

   array[0]="windows10-Enterprise"
   array[1]="Windows10-Pro"
   array[2]="Windows10-Enterprise-LTSC "
   array[3]="Windows8.1O-EM"
   array[4]="Windows8-Enterprise"
   array[5]="Windows8.1-Pro"
   array[6]="Windows7-Professional"
   array[7]="Windows7-Enterprise"
   array[8]="Windows7-Ultimate"
   array[9]="Windows-Vista-Business"
   array[10]="WindowsXP-Professional"
   array[11]="macOS11"
   array[12]="OSX10.11"
   array[13]="MacBook-Air"
   array[14]="MacBook"
   array[15]="MacBook-Pro"
 size=${#array[@]}
index=$(($RANDOM % $size))

echo "${array[$index]}" > /etc/hostname
sed -i
's/hostname_changer_status="Disable"/hostname_changer_status="Enable"/g' $SRCDIR
  info "Hostname changer successfully enabled"
 else
  warn "Hostname changer is already running"
 fi

}=
stop_hostname_changer(){
 
 cat $BACKUPDIR/hostname.bak > /etc/hostname && rm -fr $BACKUPDIR/hostname.bak
   sed -i
 's/hostname_changer=status="Enable"/hostname_changer_status="Disable"/g' $SRCDIR
  info "Hostname changer successfully disabled"
}