#!	/usr/local/bin/bash

################################################################################
#
#   配置项

#   include lib
this_file=`pwd`"/"$0

DEPLOY_TOOLS_DIR=`dirname $this_file`
. $DEPLOY_TOOLS_DIR/conf.sh
. $DEPLOY_TOOLS_DIR/utils.sh

LOGPATH="/web/soft/project/cp_instant_log/"

################################################################################
# 使用帮助
if [ $# -lt 1 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
	cecho "用法: $0 content date [logname] [line num]"
	exit 0;
fi

date=$2
if [ -z $date ]; then
	date=$(date +%Y%m%d)
fi

logname=$3
linenum=$4
if [ -z $linenum ]; then
	linenum=10
fi

echo $online_test"-------------------------------------"
if [ -z $logname ]; then
	grep $1 ${LOGPATH}${date}/* |grep $1 --color
else
	if [ -z $1 ]; then
		cat ${LOGPATH}${date}/${logname}* |tail -${linenum}
	else
		grep $1 ${LOGPATH}${date}/*${logname}* |grep $1 --color
	fi
fi
	
	
for host in $online_cluster
do
	echo $host"-------------------------------------"
	if [ -z $logname ]; then
		ssh $host "grep $1 ${LOGPATH}${date}/*" |grep $1 --color
	else
		if [ -z $1 ]; then
			ssh $host "cat ${LOGPATH}${date}/${logname}* |tail -${linenum}"
		else
			ssh $host "grep $1 ${LOGPATH}${date}/*${logname}*" |grep $1 --color
		fi
	fi
done