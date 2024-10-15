#!/bin/bash
#set -x

YAML_FILE=sample-fstab.yml
OFILE=fstab
declare -a dev


dev=$(yq 'to_entries | .[] | .value'  $YAML_FILE | yq  'to_entries | .[] | .key' | tr -d '"')

##check if the fstab list is emplty
if [[ -z "$dev" ]]; then
   echo "No FS lists provided for fstab, Exiting!"
   exit 1
else
	echo "creating fstab file in current directory"
	echo "" >$OFILE
fi


create_nfs_entry() {
	EXPORT=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.export | tr -d '"' )
	MOUNT=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.mount | tr -d '"' )
        FSTYPE=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.type | tr -d '"')
        OPTIONS=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.options[] | tr -d '"' ) 

        if [[ $OPTIONS == "" ]]; then
                OPTION_LIST="defaults"
        else
                a=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.options[] | tr -d '"' )
                OPTION_LIST=$( echo $a|sed 's/ /,/g')
        fi

	#creating entry
	echo 'Adding entry to fstab: '\"$1:$EXPORT  $MOUNT $FSTYPE $OPTION_LIST 0 2\"
        echo "$1:$EXPORT  $MOUNT $FSTYPE $OPTION_LIST 0 2" >> $OFILE

}

create_localFS_entry() {
	MOUNT=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.mount | tr -d '"' )
        FSTYPE=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.type | tr -d '"' )
	OPTIONS=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.options[]| tr -d '"' ) 
	ROOT_RESERVE=$( cat $YAML_FILE | yq .fstab.'"'$1'"'.'"root-reserve"' | tr -d '"' | tr -d '%'  )
 
        if [[ $OPTIONS == "" ]]; then 
		OPTION_LIST="defaults"
       	else 
		a=$(  cat $YAML_FILE | yq .fstab.'"'$1'"'.options[] | tr -d '"'  )
		OPTION_LIST=$( echo $a|sed 's/ /,/g')
	fi

	if [[ $ROOT_RESERVE != null ]]; then
	        OPTION_LIST="$OPTION_LIST"',createopts="-m '$ROOT_RESERVE'"'
	fi	

	#creating entry for this fs $1
	if [[ "$MOUNT" == "/" ]]; then
		echo 'Adding entry to fstab: '\"$1:$EXPORT  $MOUNT $FSTYPE $OPTION_LIST 0 1\"
        	echo "$1  $MOUNT $FSTYPE $OPTION_LIST 0 1" >> $OFILE
	else
		echo 'Adding entry to fstab: '\"$1:$EXPORT  $MOUNT $FSTYPE $OPTION_LIST 0 2\"
		echo "$1  $MOUNT $FSTYPE $OPTION_LIST 0 2" >> $OFILE
	fi
	

}

for i in ${dev[@]}
do
   
   #validate if the fs is local or NFS
   if [[ $i =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
   then
	   #echo "this mount point is NFS"
           create_nfs_entry $i 2> /dev/null
   else
	   #echo "this mount point is local"
	   create_localFS_entry $i 2> /dev/null
   fi


done


