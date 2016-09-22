#!/bin/bash

baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL

tmpFile=tmp.list

if [ -f $tmpFile ] ; then
    rm $tmpFile
fi

touch $tmpFile

for line in `ls -t fileLists_done | head -n 10 ` ; do 
   cat fileLists_done/$line >> $tmpFile 
done

for line in `ls -t picoList*` ; do 
    if [ "$line" == "picoList_current.list" ] ; then continue ; fi
    if [ "$line" == "picoList_Initial.list" ] ; then continue ; fi
    if [ "$line" == "picoList_last.list" ] ; then continue ; fi

    cat $line >> $tmpFile 
done

cat $tmpFile | sort | uniq > picoList_last.list
rm -f $tmpFile
