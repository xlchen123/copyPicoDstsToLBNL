#!/bin/bash

#inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/production2/PicoProd
inFolder=/star/institutions/lbl_prod/Run14_AuAu200GeV/P16id/PicoProd/
#outFolder=/project/projectdirs/starprod/picodsts/Run14/AuAu/200GeV/physics2/P15ic
outFolder=/project/projectdirs/starprod/picodsts/Run14/AuAu/200GeV/physics2/P16id/
baseFolder=/star/u/jthaeder/copyPicoDstsToLBNL

##############################################################

if [ $# -eq 2 ] ; then
    inList=$1
    now=$2
elif [ $# -eq 1 ] ; then
    inList=$1
    now=`date +%F_%H_%M`
else
    inList=picoList_current.list
    now=`date +%F_%H_%M`
fi

##############################################################

current=${baseFolder}/picoTransferList_${now}.list

if [ -f ${current} ] ; then
    rm ${current}
fi

touch ${current}

# -- MAKE FILELIST
##############################################################
echo "-> Prepare Transfer.."

for inFile in `cat ${inList}` ; do 
    outFile=`echo ${inFile} | sed "s|${inFolder}|${outFolder}|g"`
#    echo "jthaeder#star4${inFile} nersc#pdsf${outFile}" >> ${current}
    echo "jthaeder#star4${inFile} nersc#dtn${outFile}" >> ${current}
done

# -- TRANSFER
##############################################################
echo "-> Transfer.."

nFiles=`cat ${current} | wc -l`

if [ $nFiles -ge 1 ] ; then
    cat ${current} | ssh cli.globusonline.org transfer --label=picoDst_${now}
fi

# -- CLEANUP
##############################################################
mkdir -p ${baseFolder}/processing_tranferList

if [ $nFiles -ge 1 ] ; then
    mv ${current} ${baseFolder}/processing_tranferList/ 
else
    rm $current
fi
