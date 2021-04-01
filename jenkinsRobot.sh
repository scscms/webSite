#!/bin/bash

#=============================================================================================
#插件名称：企业微信机器人消息通知
#使用方式：curl https://www.xxx.com/jenkins.sh |bash -s "企业微信机器人webhook key" "构建描述"
#=============================================================================================
set -e

#打印日志
function log() {
    echo "$(date):$@"
}

#捕捉错误
function error() {
    local job="$0"      # job name
    local lastline="$1" # line of error occurrence
    local lasterr="$2"  # error code
    log "ERROR in ${job} : line ${lastline} with exit code ${lasterr}"
    exit 1
}

#发送信息
function sendNotifications() {
    curl  "$webhook_url" \
    -H 'Content-Type: application/json' \
    -X POST --data "{  \"msgtype\": \"markdown\", \"markdown\": { \"content\": \"$info_content\" }}"
}

trap 'error ${LINENO} ${?};' ERR

webhook_key="${1}" # 参数1：企业微信群机器人webhook的key
buildStatus="${2}" # 参数2：构建状态
webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?&key=${webhook_key}"

deploytime=$(date "+%Y-%m-%d %H:%M:%S") #时间
commitMessage=$(/usr/bin/git log --oneline -n 1) #提交信息
commitAuthorName=$(/usr/bin/git --no-pager show -s --format='%an' HEAD) #提交作者
commitAuthorEmail=$(/usr/bin/git --no-pager show -s --format='%ae' HEAD) #提交邮箱

if [ ! -n "$1" ]; then
    log "缺少webhook key"
    exit 1
fi

info_content=" -----------自动化部署消息通知---------- \n >项目名: <font color='info'>${JOB_NAME}</font> \n >构建状态: <font color='warning'>$buildStatus</font> \n >git分支：<font color='warning'>${GIT_BRANCH}</font> \n >时间：<font color='comment'>$deploytime</font> \n >提交者：<font color='comment'><font color='warning'>$commitAuthorName</font><$commitAuthorEmail></font> \n >提交日记：<font color='comment'>$commitMessage</font> \n >构建日志：[$BUILD_TAG](${BUILD_URL}console)"

sendNotifications
