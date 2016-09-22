#!/bin/bash

baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL

##############################################################

current=`readlink picoList_current.list`
current=`basename $current`

for line in `ls $baseFolder | grep picoList` ; do 

    if [ "$line" = "picoList_current.list" ] ; then
	continue
    elif [ "$line" = "picoList_last.list" ] ; then
	continue
    elif [ "$line" = "${current}" ] ; then
	continue
    fi

    string=${line%.list}
    string=${string#picoList_}

    echo "Checking status of ... ${string}"

    ssh cli.globusonline.org status | grep ${string} > /dev/null

    if [ $? -eq 1 ] ; then
      	mv $line fileLists_done
    fi

done

for line in `ls $baseFolder | grep failedList` ; do 

    if [ ! -s $line ] ; then
	rm $line
    else
	mv $line fileLists_failed
    fi
done
