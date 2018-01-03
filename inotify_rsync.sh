#!/bin/sh
# make sure user login from src server to dest server by ssh-key

src=/home/user/source # local base path
dest=/home/user/dest  # remote destinate path
user=sync_user
opt=''
SERVERS='10.0.0.1 10.0.0.2'

sync_one()
{
  echo "Pushing "$1
  #echo "/usr/bin/rsync -av $opt $src$2 ${user}@$1:$dest$2"
  /usr/bin/rsync -av $opt $src$2 ${user}@$1:$dest$2
}

sync_all()
{
  #. /home/user/servers.sh 
  for S in $SERVERS
  do
      sync_one $S $1
  done
}

inotify_file()
{
  cd $src
  /usr/bin/inotifywait -mrq --format '%Xe %w%f' -e modify,create,delete,attrib,close_write,move ./ | while read file
  do
    INO_EVENT=$(echo $file | awk '{print $1}')      
    INO_FILE=$(echo $file | awk '{print $2}')  
    #if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]
    if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]]
    then
      if [ -d "$INO_FILE"]
      then  
        opt=''
        sync_all $INO_FILE
      fi
    fi
    if [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]
    then
      opt=''
      sync_all $INO_FILE
    fi
    if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
    then
        opt=--delete
        sync_all
    fi
    if [[ $INO_EVENT =~ 'ATTRIB' ]]
    then
      if [ ! -d "$INO_FILE" ]
      then
        opt=''
        sync_all $INO_FILE
      fi
    fi
  done
}

process=$0
pid=$$
cur=`ps -ef |grep $process |grep -v grep |grep -v $pid |grep -v $PPID`
#echo $cur
if [ "_$cur" = "_" ]; then
  echo "start running"
  inotify_file
else
  echo "process has running"
fi 
exit 1