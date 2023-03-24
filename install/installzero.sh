#!/bin/sh

SVC_PATH="/tmp/zero.tar.gz"
logger -t "【ZeroTier】" "开始从GitHub下载脚本，请稍候..."
if [ ! -d "/etc/storage/zerotier-one" ] ; then
  mkdir -p /etc/storage/zerotier-one
fi
if [ -f "/etc/storage/zerotier.sh" ] ; then
mkdir -p /etc/storage/zerotierbackup
mv -f /etc/storage/zerotier.sh /etc/storage/zerotierbackup/zerotier.sh
[ -f "/etc/storage/zerotierbackup/zerotier.sh" ] && logger -t "【ZeroTier】" "检测到已有/etc/storage/zerotier.sh，脚本冲突,已移动到/etc/storage/zerotierbackup/zerotier.sh"
fi    
rm -rf /tmp/zeroMD5.txt
rm -rf /tmp/zero.tar.gz
if [ ! -e "$SVC_PATH" ] || [ ! -s "$SVC_PATH" ] ; then
       wgetcurl.sh "/tmp/zeroMD5.txt" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.5/zeroMD5.txt"  
       wgetcurl.sh "/tmp/zero.tar.gz" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.5/zero.tar.gz"
       zMD5="$(cat /tmp/zeroMD5.txt)"
       [ -f "/tmp/zero.tar.gz" ] && eval $(md5sum "/tmp/zero.tar.gz" | awk '{print "MD5_d="$1;}') && echo "$MD5_d"
       if [ "$zMD5"x = "$MD5_d"x ] ; then
       tar -xzvf /tmp/zero.tar.gz -C /tmp
       logger -t "【ZeroTier】" "下载完成，MD5匹配，开始解压..."
       else
       logger -t "【ZeroTier】" "下载完成，MD5不匹配，删除...请重新输入安装命令再次下载"
       rm -rf /tmp/zeroMD5.txt
       rm -rf /tmp/zero.tar.gz
       exit 1
       fi
fi
if [ -f "/tmp/zero123/zeroup.sh" ] ; then
       rm -rf /tmp/zero.tar.gz
       chmod 777 /tmp/zero123/*
       mv -f /tmp/zero123/zerotier.sh /etc/storage/zerotier.sh
       [ -f "/etc/storage/zerotier.sh" ] && chmod 777 /etc/storage/zerotier.sh
       [ ! -f "/etc/storage/zerotier.sh" ] && logger -t "【ZeroTier】" "下载失败，请使用手动安装" && exit 1   
fi
sleep 10
[ -f "/tmp/zero123/zeroup.sh" ] && [ -f "/etc/storage/zerotier.sh" ] && /tmp/zero123/zeroup.sh
