#!/bin/sh

this_file=`pwd`"/"$0
DEPLOY_TOOLS_DIR=`dirname $this_file`
. $DEPLOY_TOOLS_DIR/conf.sh

sync_one()
{
	echo "Pushing "$1
	/usr/bin/rsync -av --exclude "server_conf.php" --delete $REMOTE_DEPLOY_DIR"/" $SSH_USER@$1:$REMOTE_DEPLOY_DIR"/"
}
write_log()
{
	ymdhis=$(date "+%Y-%m-%d %H:%M:%S")
	ymd=$(date "+%Y%m%d")
	logfile=/home/$SSH_USER/sync_log/$ymd.log
	message=$ymdhis' carnival_web source code sync success'
	echo $message >> $logfile
}
SERVERS=$online_cluster
for S in $SERVERS
do
    sync_one $S
done
#log record
write_log
