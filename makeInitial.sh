#!/bin/bash

baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL
#inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/production2/PicoProd/
inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/P16id/PicoProd/

delay=5       # in minutes

##############################################################
now=`date +%F_%H_%M`

current=${baseFolder}/picoList_${now}.list
failed=${baseFolder}/failedList_${now}.list
tmp_current=${baseFolder}/picoList_${now}_tmp.list 

##############################################################

if [ -f ${current} ] ; then
    rm ${current}
fi

touch ${current}


if [ -f ${failed} ] ; then
    rm ${failed}
fi

touch ${failed}

##############################################################
echo "find"
find ${inFolder} -name *.root -not -cmin -${delay} > $tmp_current
echo "checkif file exists and non zero"
while read -r line ; do
    if [[ -s ${line} && -r ${line} ]] ; then 
	echo ${line} >> ${current}
    else
	echo ${line} >> ${failed}
    fi
done < <(cat ${tmp_current})

if [ -f ${tmp_current} ] ; then
    rm ${tmp_current}
fi

ln -s  ${current}  picoList_current.list

##############################################################

echo "starting Transfer ....  "
sleep 5

./makeTransfer.sh picoList_current.list ${now}
