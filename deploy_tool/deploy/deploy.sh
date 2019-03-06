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
if [ $# -lt 2 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ]
then
    if [ "$DEPLOY_BETA" != "online_test" ]
    then
        script="qa"
    else
        script="ot"
    fi
    cecho "发送一个分支到指定测试服务器：";
	cecho "用法: \e[1;32msh deploy-${script}.sh 分支名称 测试机编号\e[0m";
    cecho "\n"
    cecho "部署Example:"
    cecho "将dev分支发送到QA 2号测试机上: \e[1;32msh deploy-qa.sh dev 2\e[0m";
    cecho "将add_cache_20141016分支发送到第三组线上测试机上: \e[1;32msh deploy-ot.sh add_cache_20141016 3\e[0m";
	cecho "\e[1;31m部署分支无需push到远程分支，本地commit提交即可\e[0m";
    cecho "\n"
    cecho "初始化Example:"
    cecho "第二组线上测试机初始化回归机代码: \e[1;32msh deploy-ot.sh init 2\e[0m";
	cecho "\e[1;31m代码初始化只提供线上测试机\e[0m";
    cecho "\n"
    cecho "占用释放Example:"
    cecho "释放对QA 3号回归机的占用: \e[1;32msh deploy-qa.sh clean 3\e[0m";
    cecho "释放对第一组线上测试机的占用: \e[1;32msh deploy-ot.sh clean 1\e[0m";
	cecho "\e[1;31m占用环境和解除占用必须是同一人\e[0m";
    cecho "\n"
	exit 0;
fi


init

####################################################################################################
#git archive master | tar -x -C ../working
CURRENT_TIME=$(now)
if [ ! -d $LOCAL_TMP_DIR ]; then
    mkdir -p $LOCAL_TMP_DIR -m 0777
fi

if [ "$DEPLOY_BETA" != "online_test" ]
then 
    hosts=${qa[$2]}
else
    hosts=${online_test[$2]}
    if [ "$1" == "init" ]
    then 
        for host in ${hosts}
        do
            cecho "初始化... ${host}"
            cecho "初始化完成：${host}"
        done
        exit;
    fi
fi
######################################清除占位#####################################################
if [ "$1" == "clean" ]
then 
    for host in ${hosts}
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

######################################打包#########################################################

src_tgz="${LOCAL_TMP_DIR}/code_${PROJECT_NAME}_${CURRENT_TIME}.tar"
cecho "开始打包分支..."
git archive $1 > ${src_tgz}
cecho "分支打包完成"
if [[ ! -s $src_tgz ]]; then
    cecho "找不到对应分支"
    exit;
fi

######################################上线#########################################################
for host in ${hosts}
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
	$SSH $host "cd ${REMOTE_DEPLOY_DIR}; sh project/autoload_builder.sh >> /dev/null;"
    cecho "代码解压到：$REMOTE_DEPLOY_DIR"
    cecho "上线完成：\e[1;31m$host\e[0m"
    if [ -z $who ]; then
        $SSH $host "$EXPORT_LANGUAGE;echo \"${USER}\" > ${ONLINE_BACKUP_DIR}/who"
    fi
done
