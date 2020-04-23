#!/bin/bash

## 	This program extracts all programs individually from
#	the *.ALL into individual files.
#
#	Applicable to FANUC version
#		0i, 16i, 18i, 31i
#
#	Runs on Linux, Android and Windows 
#	(with additional installation of a Linux shell from Microsoft-Store)
#
#	Coded by Sebastian Staitsch
#	s.staitsch@gmail.com
#	Version 1.3
#	last modified: 2020/04/23 20:35:02
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
	get_ver(){
		if [ "$(egrep -o '<|>' $file)" ] ; then v=31
		elif [ "$(egrep -o '^O{1}[0-9]{4}' $file)" ] ; then v=18
		else 
		return 10 ; exit
		fi
	}

#READ PROGRAMM-NAME
	read_oname(){
		if [ "$v" = "18" ]; then ONAME=$(egrep -om1 'O{1}[0-9]{4}' $file)
		elif [ "$v" = "31" ]; then ONAME=$(egrep -om1 '^<{1}\S*>{1}' $file | tr -d '<>')
		else exit
		fi
	}

#DELETE CR/LF AND PRERCENT-SYMBOL
	del_crlf(){
		cat $file | tr -d '\r%' > .tmp ; rm $file ; mv .tmp $file
	}
	
#READ FIRST LINE
	read_line(){
		line_1=$(cat $file | head -1)
	}
	
#DELETE FIRST LINE
	del_line(){
		tail -n+2 $file > .tmp ; rm $file ; mv .tmp $file
	}
	
#LOOP VERSION 18
	loop_18(){	
		until [ "$(cat $file | wc -l)" = 0 ]; do
			read_line
			if [ $(echo $line_1 | egrep -o 'O{1}[0-9]{4}') ]; then 
				read_oname
				echo $line_1
				echo $v$file/$ONAME  $line_1  >> list.txt
			fi
			echo $line_1 >> $v$file/$ONAME
			del_line
			done
	}
	
#LOOP VERSION 31
	loop_31(){	
		read_oname
		until [ "$(cat $file | wc -l)" = 0 ]; do
			read_line
			if [ $(echo $line_1 | egrep -o '^<') ]; then 
				read_oname
				echo $line_1
				echo $v$file/$ONAME  $line_1  >> list.txt
			fi
			echo $line_1 >> $v$file/$ONAME
			del_line
			done
	}
	
#MAIN PROGRAMM
	if [ ! $( ls *.ALL 2>/dev/null ) ] ; 
	then echo "No *.ALL Files found" ; sleep 2 ; exit ; fi
	
	for file in *ALL ; do 
		echo ======================================
		echo NOW SPLIT FILE $file  
		echo ======================================
		cp $file $file.bak
		del_crlf
		get_ver
		mkdir $v$file
		if [ "$v" = "18" ]; then loop_18
			elif [ "$v" = "31" ]; then loop_31
			else
			return 1000; exit
		fi
		rm $file
		mv $file.bak $file
		echo ======================================
		echo "Extracted $(ls $v$file | wc -l ) Files."
		echo ======================================
	done

#ADD PERCENT-SYMBOL TO EVERY FILE
	for file in */*; do
		echo "%" > $file.tmp
		cat $file >> $file.tmp
		echo "%" >> $file.tmp
		rm $file
		mv $file.tmp $file
	done
		
#SORT PROGRAMMLIST
	cat list.txt | sort > prg_list.txt
	rm list.txt
