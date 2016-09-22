#!/bin/bash

callSleep() {
    nowSleep=`date '+%F %H:%M'`
#    till=`date -d "5 hours" '+%F %H:%M'`
    till=`date -d "2 hours" '+%F %H:%M'`
#    till=`date -d "12 hours" '+%F %H:%M'`
    echo "It is ${nowSleep} ... sleeping ${sleepInterval}s - till ${till}"
    sleep ${sleepInterval}
}

baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL
#inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/production2/PicoProd/
inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/P16id/PicoProd/

delay=5       # in minutes
interval=12   # in hours

#sleepInterval=43200 # in seconds (12 h)
#sleepInterval=18000 # in seconds (5 h)
sleepInterval=7200 # in seconds  (2 h) 

##############################################################
 
now=`date +%F_%H_%M`

echo "Start $now"

##############################################################

current=${baseFolder}/picoList_${now}.list
failed=${baseFolder}/failedList_${now}.list
tmp_current=${baseFolder}/picoList_${now}_tmp.list 

##############################################################

echo "Call createLastList"
./createLastList.sh

##############################################################

if [ -f ${baseFolder}/picoList_last.list ] ; then 
    previous=${baseFolder}/picoList_last.list
elif [ -h ${baseFolder}/picoList_current.list ] ; then 
    echo "No Last file ..."
    previous=${baseFolder}/picoList_current.list
    previousOrig=`readlink ${previous}`
    if [ "${current}" = "${previousOrig}" ] ; then
	echo "Current is previous ... break"

	callSleep
	exit
    fi
else
    echo "No Previous file ... break"
    callSleep
    exit
fi

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
echo "Create picoList"
let start=interval*60+delay 

# -- find all within the last 6 hours and 15 min - without the last 15 min
#find ${inFolder} -name *.root -cmin -${start} -not -cmin -${delay} > ${tmp_current}

# look for all now but not from the last ${delay} min 
find ${inFolder} -name *.root -not -cmin -${delay} > ${tmp_current} 

echo "Clean picolist"
while read -r line ; do
    grep ${line} ${previous} > /dev/null
    ret=$?
    
    if [ ${ret} -eq 0 ] ; then
	continue
    fi
    
    if [[ -s ${line} && -r ${line} ]] ; then 
	echo ${line} >> ${current}
    else
	echo ${line} >> ${failed}
    fi

done < <(cat ${tmp_current})

if [ -f ${tmp_current} ] ; then
    rm ${tmp_current}
fi

##############################################################

nFiles=`cat ${current} | wc -l`

if [ $nFiles -eq 0 ] ; then
    echo "No new files ..."
    rm ${current}

    callSleep
    exit
fi

##############################################################

if [ -h ${baseFolder}/picoList_current.list ] ; then
    rm ${baseFolder}/picoList_current.list
fi

ln -s ${current} ${baseFolder}/picoList_current.list

##############################################################

echo "Call MakeTransfer"
./makeTransfer.sh picoList_current.list ${now}

##############################################################

callSleep

##############################################################
echo "Check for faulty files"
./faultyFiles.sh

echo "Call CleanUp"
./cleanUp.sh



