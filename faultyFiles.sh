#!/bin/bash

for ii in `ssh cli.globusonline.org status | grep "Task ID" | awk -F' : ' '{print $2}'` ; do 


    nEvents=`ssh cli.globusonline.org events --faults $ii | grep "File:" | sort | uniq | awk -F 'File: ' '{print $2}' | wc -l`
    pending=`ssh cli.globusonline.org details $ii | grep "Tasks Pending" | awk -F' : ' '{print $2}'`
    retrying=`ssh cli.globusonline.org details $ii | grep "Tasks Retrying" | awk -F' : ' '{print $2}'`
    failed=`ssh cli.globusonline.org details $ii | grep "Tasks Failed" | awk -F' : ' '{print $2}'`
    label=`ssh cli.globusonline.org details $ii | grep "Command" | awk -F'=' '{print $2}' | awk -F'(' '{print $1}'`

    echo "task: $ii | $label"
    echo "  pending: $pending | retrying: $retrying | failed: $failed"

    if [ $pending -eq $retrying ] ; then
	echo " ... cancel task" 
	ssh cli.globusonline.org events --faults $ii | grep "File:" | sort | uniq | awk -F 'File: ' '{print $2}'
	ssh cli.globusonline.org events --faults $ii | grep "File:" | sort | uniq | awk -F 'File: ' '{print $2}' >> fileLists_failed/new.lixt
        ssh cli.globusonline.org cancel $ii
    fi
    echo "------------------------------------------------------------------"
done

