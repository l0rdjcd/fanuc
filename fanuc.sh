#!/bin/bash

## 	This program extracts all programs individually from
#	the *.ALL or *.CNC into individual files.
#
#	Applicable to FANUC version
#		0i, 16i, 18i, 31i
#
#	Runs on Linux, Android and Windows 
#	(with additional installation of a Linux shell from Microsoft-Store)
#
#	Coded by Sebastian Staitsch
#	s.staitsch@gmail.com
#	Version 1.2 Final
#	last modified: 2020/04/20 20:44:35
#	https://github.com/sstaitsch/fanuc
#	https://pastebin.com/4wFFYnw3
#
#	=== VIDEO ===
#	https://youtu.be/zgsBnk39xLI
#
#	NOTE: Files must be in the same folder as the script file
#	USE: sh fanuc.sh

########### BEGIN FUNCTIONS ###########

#GET VERSION
	ver_get(){
			if [ "$( egrep -o '<|>' $file)" ] ; then ver=31
				elif [ "$( egrep -o '<|>' $file )" = "" ] ; then ver=18
			else ver=0
			fi
	}

#DELETE CR/LF
	del_crlf(){
		cat $file | tr -d '\r' > .tmp ; rm $file ; mv .tmp $file
	}

#WRITE FILE
	write_file(){
		if [ -e $ver/$O_NAME ] ; then
			(( cnt ++ ))
			O_NAME2="$O_NAME-$cnt"
			echo "%" > $ver/$O_NAME2
			cat $file | head -$O_LNe >> $ver/$O_NAME2
			echo "%" >> $ver/$O_NAME2
			echo $( head -2 $ver/$O_NAME2 | tail -n1 ) >> $ver/list.txt
		else
			echo "%" > $ver/$O_NAME
			cat $file | head -$O_LNe >> $ver/$O_NAME
			echo "%" >> $ver/$O_NAME
			head -2 $ver/$O_NAME | tail -1
			echo $( head -2 $ver/$O_NAME | tail -n1 ) >> $ver/list.txt
		fi
	}

#DELETE FIRST LINE
	del_firstln(){
		tail -n+2 $file > tmp
		rm $file
		mv tmp $file
	}

#DELETE LINES AFTER WRITE
	del_ln(){
			O_LNe=$( expr $O_LNe + 1 )
			cat $file | tail -n+$O_LNe > tmp
			rm $file
			mv tmp $file
	}

#FANUC 18
	loop18(){
		cnt=0
		cp $file $file.bak
		mkdir $ver 2>/dev/null
		del_firstln
		until [ "$( cat $file | wc -l )" = "0" ] ; do
			O_NAME=$( egrep -o '^O{1}[0-9]{4}' $file | head -1 )
			O_LNb=$( egrep -no '^O{1}[0-9]{4}' $file | egrep -o '^[0-9]{1,4}' | head -1 )
			O_LNe=$( egrep -no '^O{1}[0-9]{4}|^#3000{1}|^%{1}' $file | head -2 | tail -n+2 | egrep -o '^[0-9]{1,4}')
			O_LNe=$( expr $O_LNe - 1 )
			write_file
			del_ln
		done
		mv $file.bak $file
	}

#FANUC 31
	loop31(){
		cnt=0
		cp $file $file.bak
		mkdir $ver 2>/dev/null
		del_firstln
		until [ "$( cat $file | wc -l )" = "0" ] ; do
			O_NAME=$( egrep -o '^<{1}\S*>{1}' $file | tr -d '<>' | head -1 )
			O_LNb=$( egrep -no '^<{1}' $file | egrep -o '^[0-9]{1,3}' | head -1 )
			O_LNe=$( egrep -no '^<.*>|^%{1}' $file | head -2 | tail -n-1 | egrep -o '^[0-9]{1,4}')
			O_LNe=$( expr $O_LNe - 1 )
			write_file
			del_ln
		done
		mv $file.bak $file
	}

########### END FUNCTIONS ###########

#MAIN PROGRAM
	if [[ ! $( ls *.ALL 2>/dev/null ) && ! $( ls *.CNC 2>/dev/null ) ]] ; 
	then echo "No *.CNC or *.ALL Files found" ; sleep 2 ; exit ; fi
	for file in *ALL ; do
		del_crlf
		ver_get
		if [ "$ver" = "31" ] ; then cnt=0 ; loop31
				echo "Extracted $(ls $ver | wc -l ) Files. Found $( md5sum 18/* | sort | uniq -D -w 32 | wc -l ) duplicates"
				md5sum 31/* | sort | uniq -D -w 32 > $ver/md5_duplicates.txt
				md5sum 31/* | sort > $ver/md5_all.txt

			elif [ "$ver" = "18" ] ; then loop18
				echo "Extracted $(ls $ver | wc -l ) Files. Found $( md5sum 18/* | sort | uniq -D -w 32 | wc -l ) duplicates"
				md5sum 18/* | sort | uniq -D -w 32 > $ver/md5_duplicates.txt
				md5sum 18/* | sort > $ver/md5_all.txt

			elif [ "$ver" = "0" ] ; then echo "unknown File" ; exit
		else
		echo "Error detecting File" ; exit
		fi
	done
	d=$(date +"%Y-%m-%d_%H:%M")
	if [ -d 31/ ] ; then mv 31/ fanuc_31-$d/ ; fi
	if [ -d 18/ ] ; then mv 18/ fanuc_18-$d/ ; fi
