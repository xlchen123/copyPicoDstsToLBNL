#!/bin/bash

baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL
inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/production/PicoProd/

pdsfList=/project/projectdirs/starprod/picodsts/Run14/AuAu/200GeV/fileLists/picoList_all.list

delay=5       # in minutes

##############################################################

pdsfFileName=`basename $pdsfList`

if [ -f ${baseFolder}/cmp/${pdsfFileName} ] ; then 
    rm ${baseFolder}/cmp/${pdsfFileName}
fi

scp pdsf.nersc.gov:${pdsfList} ${baseFolder}/cmp

##############################################################

rcfFileName=src.list

find ${inFolder} -name *.root -not -cmin -${delay} > ${baseFolder}/cmp/$rcfFileName

##############################################################

missing=${baseFolder}/cmp/missing.list

if [ -f ${missing} ] ; then
    rm ${missing}
fi

touch ${missing}

while read -r line ; do

    
    grep `basename ${line}` ${baseFolder}/cmp/${pdsfFileName} > /dev/null
    ret=$?
    
    if [ ${ret} -eq 0 ] ; then
	continue
    fi
    
    echo $line >> $missing

done < <(cat ${baseFolder}/cmp/$rcfFileName )

