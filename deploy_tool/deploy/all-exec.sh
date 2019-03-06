#!	/usr/local/bin/bash

################################################################################
#
#   配置项

#   include lib
this_file=`pwd`"/"$0

DEPLOY_TOOLS_DIR=`dirname $this_file`
. $DEPLOY_TOOLS_DIR/conf.sh
. $DEPLOY_TOOLS_DIR/utils.sh

################################################################################
# 使用帮助
if [ $# -lt 1 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
	cecho "用法: $0 cmd"
	exit 0;
fi


for host in $online_cluster
do
	cecho "\n=== $host  === \n" $c_notify
	ssh $host $@
done
