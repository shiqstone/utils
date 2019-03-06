#!/bin/bash


####################################################################################################
#   配置项

#   include lib
this_file=`pwd`"/"$0

DEPLOY_TOOLS_DIR=`dirname $this_file`
. $DEPLOY_TOOLS_DIR/conf.sh
. $DEPLOY_TOOLS_DIR/utils.sh


####################################################################################################
# 使用帮助
if [ $# -lt 1 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
	cecho "用法: $0 FILE";
	cecho "FILE* :  revert 所使用的备份文件"
	cecho "用法: $0 ls";
  	cecho "列出部署的历史，每次备份的文件位置"
	exit 0;
fi

###################################################################################################
if [ $1 == "ls" ]
then
	no=0
  while read line
  do
		no=`echo "$no + 1" | bc`
		cecho "$no	$line";
  done < $DEPLOY_HISTORY_FILE
  exit 0;
fi

revert_src_tgz=$1

cecho "开始回滚,原备份文件:$revert_src_tgz"
for host in $online_test
do
    cecho "\n"
    cecho "开始上传原备份代码到：$host"
    uploaded_src_tgz="$ONLINE_BACKUP_DIR/"$(basename $revert_src_tgz)
    $SCP $revert_src_tgz $host:$uploaded_src_tgz > /dev/null
    cecho "已上传原备份代码包到：$uploaded_src_tgz"
    cecho "开始解压原备份代码包..."
	$SSH $host "$EXPORT_LANGUAGE;tar -xf $uploaded_src_tgz -C ${REMOTE_DEPLOY_DIR}"
	cecho "原备份代码已解压到：$REMOTE_DEPLOY_DIR"
	$SSH $host "cd ${REMOTE_DEPLOY_DIR}; sh project/autoload_builder_online.sh >> /dev/null;"
	cecho "开始同步线上服务器..."
	$SSH $host "cd ${REMOTE_DEPLOY_DIR}; sh deploy/sync_online.sh >> /dev/null;"
    cecho "\e[1;31m回滚完成：$host\e[0m"
done

