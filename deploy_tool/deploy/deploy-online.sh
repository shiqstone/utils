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
if [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
    script="ot";
    cecho "发送master的最新版本到指定测试服务器：";
	cecho "用法: \e[1;32msh deploy-${script}.sh \e[0m";
    cecho "\n"
    cecho "发送master的某一版本到最新版本之间修改的文件到指定测试服务器：";
	cecho "用法: \e[1;32msh deploy-${script}.sh 某一版本号 \e[0m";
    cecho "\n"
    cecho "发送master的某一较旧版本到另一较新版本之间修改的文件到指定测试服务器：";
	cecho "用法: \e[1;32msh deploy-${script}.sh 某一较旧版本号 另一较新版本号\e[0m";
    cecho "\n"
	exit 0;
fi

init

CURRENT_TIME=$(now)
if [ ! -d $LOCAL_TMP_DIR ]; then
    mkdir -p $LOCAL_TMP_DIR -m 0777
fi


######################################清除占位#####################################################
if [ "$1" == "clean" ]
then 
    for host in $online_test
    do
        who=`$SSH $host "$EXPORT_LANGUAGE;cat ${ONLINE_BACKUP_DIR}/who 2>/dev/null"`
        if [ ! -z $who ]; then
            if [ "$USER" != "$who" ]; then
                cecho "\e[1;31m${host}\e[0m环境已被\e[1;31m${who}\e[0m占用，请协调"
                continue
            fi
        fi
        $SSH $host "$EXPORT_LANGUAGE;echo "" > ${ONLINE_BACKUP_DIR}/who"
        cecho "占用释放：\e[1;31m${host}\e[0m"
    done
    exit;
fi

######################################获取并比对差异文件#########################################################
git pull
UPFILES=""
GITBRANCH=$(git branch |awk '{print $2}')
if [ $GITBRANCH != "master" ] 
then
	cecho "\e[1;32m本地分支不是master,请切换到master再操作\e[0m"
	exit 0
fi
if [ $# == 0 ] 
then
	NEWVERSION=$(git rev-parse HEAD)
	UPFILES=$(git diff $NEWVERSION $NEWVERSION"^" --name-only)
elif [ $# == 1 ] 
then
	NEWVERSION=$(git rev-parse HEAD)
	UPFILES=$(git diff $NEWVERSION $1"^" --name-only)
elif [ $# == 2 ] 
then
	UPFILES=$(git diff $1"^" $2 --name-only)
else
	cecho "\e[1;32m参数错误\e[0m"
	exit;
fi

if [ -z "$UPFILES" ] 
then
	cecho "\e[1;32m未获取到待同步的文件列表，请确认参数是否正确\e[0m"
	exit 0;
fi

NEEDUPFILES=""
for upfile in $UPFILES
do
	uptype=$(echo "$upfile"|awk -F '/' '{print $1}')
	if [ $uptype == "websocket" ]||[ $uptype == "admin" ]
	then 
		cecho "\e[1;32m忽略不需要同步的文件：$upfile\e[0m"
	elif [ $uptype == "web" ]
	then
		filepath=$(echo "$upfile"|awk '{print substr($0,5)}')
		NEEDUPFILES=$filepath" "$NEEDUPFILES
	else
		cecho "\e[1;32m忽略不需要同步的文件：$upfile\e[0m"
	fi
done

DELETEDFILES=""
cecho "\n\e[1;32m从代码仓库中获取到的待同步文件列表\e[0m："
no=0;
for needupfile in $NEEDUPFILES
do
	no=`echo "$no + 1" | bc`
	echo "$no	$needupfile"
	
	if [ ! -f $needupfile ]; then
		DELETEDFILES=$needupfile" "$DELETEDFILES
	fi
done

if [ ! -z "$DELETEDFILES" ] 
then
	cecho "\n\e[1;31m待删除文件列表\e[0m："
	no=0;
	for deletedfile in $DELETEDFILES
	do
		no=`echo "$no + 1" | bc`
		echo "$no	$deletedfile"
	done
fi
echo ""
deploy_confirm "确认待同步文件列表？"
if [ 1 != $? ]; then
	exit 1;
fi


if [ -z "$NEEDUPFILES" ] 
then
	cecho "\e[1;32m未获取到待同步的文件列表，请确认参数是否正确\e[0m"
	exit 0;
fi

echo ""
ISDIFF=1
deploy_confirm "是否需要依次比对待上线文件？"
if [ 1 != $? ]; then
	ISDIFF=0
fi

echo ""
AUTOBUILDER=1
deploy_confirm "谨慎选择: 上传代码完成后是否执行 project/autoload_builder_online.sh ？"
if [ 1 != $? ]; then
	AUTOBUILDER=0
fi

echo ""
ISOCCUPY=0
AUTOSYNC=1
deploy_confirm "谨慎选择: 是否同步到线上服务器？(不同步则会占用回归环境)"
if [ 1 != $? ]; then
	AUTOSYNC=0
	ISOCCUPY=1
fi
REALNEEDUPFILES=""
cecho "从基准机下载代码与本地对比："
LOCALPARENTPATH=""
for host in $online_test
do
	LOCALPARENTPATH=$LOCAL_TMP_DIR"/"$CURRENT_TIME"/"
	for needupfile in $NEEDUPFILES
	do
		LOCALPATH=$LOCALPARENTPATH$(dirname $needupfile)
		mkdir -p $LOCALPATH
		chmod 777 $LOCALPATH
		LOCALFILE=$LOCAL_TMP_DIR"/"$CURRENT_TIME"/"$needupfile
		$SCP $host:$REMOTE_DEPLOY_DIR"/"$needupfile $LOCALFILE
		if [ -f $LOCALFILE ]; then
			sudo chmod 777 $LOCALFILE
		fi
		if [ 1 == $ISDIFF ]; then
			NEEDUPMD5=$(md5sum $needupfile|awk '{print $1}')
			LOCALFILEMD5="false"
			if [ -f $LOCALFILE ]; then
				LOCALFILEMD5=$(md5sum $LOCALFILE|awk '{print $1}')
			fi
			if [ $LOCALFILEMD5 == $NEEDUPMD5 ]; then
				cecho "\e[1;31m\t$needupfile 无差异,无需上线!\e[0m"
			fi
			if [ $LOCALFILEMD5 != $NEEDUPMD5 ]; then
				cecho "\t$needupfile"
				sleep 1
				vimdiff $needupfile $LOCALFILE
				deploy_confirm "  修改确认 $needupfile ?"
				if [ 1 != $? ]; then
					exit 1;
				fi
				REALNEEDUPFILES=$needupfile" "$REALNEEDUPFILES
			fi
		fi
	done
	break
done

if [ 1 == $ISDIFF ]; then
	if [ -z "$REALNEEDUPFILES" ] 
	then
		cecho "\e[1;32m未获取到差异的待同步文件列表，无需上线!\e[0m"
		exit 0;
	fi
fi

######################################打包#########################################################

src_tgz="${LOCAL_TMP_DIR}/code_${PROJECT_NAME}_${CURRENT_TIME}.tar"
src_bak_tgz="${LOCAL_TMP_DIR}/code_${PROJECT_NAME}_${CURRENT_TIME}_bak.tar"
cecho "开始打包代码..."

if [ 1 == $ISDIFF ]; then
	tar -cf $src_tgz $REALNEEDUPFILES
else
	tar -cf $src_tgz $NEEDUPFILES
fi

currpath=`pwd`
cd $LOCALPARENTPATH && tar -cf $src_bak_tgz ./*
cd $currpath

rm -rf $LOCALPARENTPATH

cecho "代码打包完成"
if [[ ! -s $src_tgz ]]; then
    cecho "\e[1;32m找不到打包后代码\e[0m"
    exit;
fi

mkdir -p $LOCAL_DEPLOY_HISTORY_DIR
echo $src_bak_tgz $USER >> $DEPLOY_HISTORY_FILE

######################################上线#########################################################
for host in $online_test
do
    cecho "\n"
    $SSH $host "$EXPORT_LANGUAGE;mkdir -p $ONLINE_BACKUP_DIR"
    who=`$SSH $host "$EXPORT_LANGUAGE;cat ${ONLINE_BACKUP_DIR}/who 2>/dev/null"`
    if [ ! -z $who ]; then
        if [ "$USER" != "$who" ]; then
            cecho "\e[1;31m${host}\e[0m环境已被\e[1;31m${who}\e[0m占用，请协调"
            continue
        fi
    fi
    cecho "开始上传代码到：$host"
	#backup_online_src $host $backup_src_tgz "$files"
    uploaded_src_tgz="$ONLINE_BACKUP_DIR/code_${PROJECT_NAME}_${CURRENT_TIME}.tar"
    cecho "已上传代码包到：$uploaded_src_tgz"
    $SCP $src_tgz $host:$uploaded_src_tgz > /dev/null
    cecho "开始解压代码包..."
    $SSH $host "if ! test -d ${REMOTE_DEPLOY_DIR};then mkdir -p ${REMOTE_DEPLOY_DIR}; fi;"
	$SSH $host "$EXPORT_LANGUAGE;tar -xf $uploaded_src_tgz -C ${REMOTE_DEPLOY_DIR}"
	cecho "代码解压到：$REMOTE_DEPLOY_DIR"
	if [ ! -z "$DELETEDFILES" ]; then
		no=0;
		for deletedfile in $DELETEDFILES
		do
			$SSH $host "cd ${REMOTE_DEPLOY_DIR}; rm -rf $deletedfile >> /dev/null;"
		done
	fi
	if [ 1 == $AUTOBUILDER ]; then
		$SSH $host "cd ${REMOTE_DEPLOY_DIR}; sh project/autoload_builder_online.sh >> /dev/null;"
	fi
	if [ 1 == $AUTOSYNC ]; then
		cecho "\n\e[1;32m开始同步线上服务器...\e[0m"
		$SSH $host "cd ${REMOTE_DEPLOY_DIR}; sh deploy/sync_online.sh >> /dev/null;"
	fi
    cecho "\e[1;31m上线完成：$host; 备份文件:$src_bak_tgz\e[0m"
    if [ 1 == $ISOCCUPY ]; then
	    if [ -z $who ]; then
	        $SSH $host "$EXPORT_LANGUAGE;echo \"${USER}\" > ${ONLINE_BACKUP_DIR}/who"
	    fi
	fi
	if [ 0 == $ISOCCUPY ]; then
		$SSH $host "$EXPORT_LANGUAGE;echo "" > ${ONLINE_BACKUP_DIR}/who"
	fi
done
