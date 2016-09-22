#!/bin/bash

baseList=$1
checkList=$2

outList=out.List

if [ -f $outList ] ; then
    rm $outList
fi

touch $outList

while read -r line ; do
    grep ${line} ${baseList} > /dev/null
    ret=$?
    
    if [ ${ret} -eq 0 ] ; then
	continue
    fi

    echo ${line} >> ${outList}

done < <(cat ${checkList})

