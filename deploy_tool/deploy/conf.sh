#!/bin/bash

# 如果term设置的是gbk编码， 改为gbk编码
export LANGUAGE="utf-8"
#export LANGUAGE="gbk"

# 项目名
PROJECT_NAME="carnival_web"
VERSION="1.0.0-release"
GIT_URL=""

#真实的线上服务器
online_cluster="192.168.0.12 192.168.0.13"

#线上发布机
online_test="10.11.22.33"

#测试机器
qa[1]=""


# 项目部署的目录， link 到  $REAL_REMOTE_DEPLOY_DIR 上
REMOTE_DEPLOY_DIR="/home/q/system/carnival/web"

# 部署使用的账号
SSH_USER="sync_cp"

# 设置为1的时候， 会输出debug信息
UTILS_DEBUG=0

# 安装后自动执行初始化脚本

# 同上 root权限
#SUDO_AUTORUN_PACKAGE=""
#AUTORUN_PACKAGE_CMD="ls"

# 运行deploy.sh 后自动通过全路径直接运行，脚本需要有可执行权限
AUTORUN_RELEASE_CMD="cd $REMOTE_DEPLOY_DIR/;sh project/autoload_builder_online.sh"

# 用于diff命令  打包时过滤logs目录
DEPLOY_BASENAME=`basename $REMOTE_DEPLOY_DIR`
TAR_EXCLUDE="--exclude $DEPLOY_BASENAME/logs"

########## 不要修改 #########################

SSH="sudo -u $SSH_USER ssh"
SCP="sudo -u $SSH_USER scp"

LOCAL_TMP_DIR="/tmp/deploy_tools/$USER"                                   # 保存本地临时文件的目录
BLACKLIST='(.*\.tmp$)|(.*\.log$)|(.*\.svn.*)|(.*\.git.*)'                 # 上传代码时过滤这些文件
ONLINE_TMP_DIR="/tmp"                                                     # 线上保存临时文件的目录
ONLINE_BACKUP_DIR="/home/$SSH_USER/deploy_history/$PROJECT_NAME"          # 备份代码的目录
LOCAL_DEPLOY_HISTORY_DIR="/home/$USER/deploy_history/$PROJECT_NAME"
DEPLOY_HISTORY_FILE="$LOCAL_DEPLOY_HISTORY_DIR/deploy_history"            # 代码更新历史(本地文件）
DEPLOY_HISTORY_FILE_BAK="$LOCAL_DEPLOY_HISTORY_DIR/deploy_history.bak"
