#!/bin/sh
if [ -f "/etc_ro/script.tgz" ] && [ -f "/etc/storage/www_sh/menu_title.sh" ] ; then
SVC_PATH="/tmp/zero.tar.gz"
logger -t "【ZeroTier】" "开始从GitHub下载脚本，请稍候..."
echo "开始从GitHub下载脚本，请稍候..."
if [ ! -d "/etc/storage/zerotier-one" ] ; then
  mkdir -p /etc/storage/zerotier-one
fi
if [ -f "/etc/storage/zerotier.sh" ] ; then
mkdir -p /etc/storage/zerotierbackup
echo "检测到已有/etc/storage/zerotier.sh，脚本冲突,已移动到/etc/storage/zerotierbackup/zerotier.sh"
mv -f /etc/storage/zerotier.sh /etc/storage/zerotierbackup/zerotier.sh
[ -f "/etc/storage/zerotierbackup/zerotier.sh" ] && logger -t "【ZeroTier】" "检测到已有/etc/storage/zerotier.sh，脚本冲突,已移动到/etc/storage/zerotierbackup/zerotier.sh"
fi    
rm -rf /tmp/zeroMD5.txt
rm -rf /tmp/zero.tar.gz
if [ ! -e "$SVC_PATH" ] || [ ! -s "$SVC_PATH" ] ; then
       wgetcurl.sh "/tmp/zeroMD5.txt" "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/zeroMD5.txt"  
       wgetcurl.sh "/tmp/zero.tar.gz" "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/zero.tar.gz"
       zMD5="$(cat /tmp/zeroMD5.txt)"
       [ -f "/tmp/zero.tar.gz" ] && eval $(md5sum "/tmp/zero.tar.gz" | awk '{print "MD5_d="$1;}') && echo "$MD5_d"
       if [ "$zMD5"x = "$MD5_d"x ] ; then
       tar -xzvf /tmp/zero.tar.gz -C /tmp
       logger -t "【ZeroTier】" "下载完成，MD5匹配，开始解压..."
       echo "下载完成，MD5匹配，开始解压..."
       else
       logger -t "【ZeroTier】" "下载完成，MD5不匹配，删除...请重新输入安装命令再次下载"
       echo "下载完成，MD5不匹配，删除...请重新输入安装命令再次下载"
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
else
logger -t "【ZeroTier】" "检测当前padavan不是hiboy版的，开始下载其他版padavan脚本"
echo "检测当前padavan不是hiboy版的，开始下载其他版padavan脚本"
if [ -f "/etc/storage/zerotier.sh" ] ; then
mkdir -p /etc/storage/zerotierbackup
mv -f /etc/storage/zerotier.sh /etc/storage/zerotierbackup/zerotier.sh
[ -f "/etc/storage/zerotierbackup/zerotier.sh" ] && logger -t "【ZeroTier】" "检测到已有/etc/storage/zerotier.sh，脚本冲突,已移动到/etc/storage/zerotierbackup/zerotier.sh"
fi
if [ ! -d "/etc/storage/zerotier-one" ] ; then
  mkdir -p /etc/storage/zerotier-one
fi
logger -t "【ZeroTier】" "开始从GitHub下载脚本，请稍候..."
echo "开始从GitHub下载脚本，请稍候..."
if [ ! -f "/etc/storage/zerotier.sh" ] ; then
curl -L -k -S -o "/etc/storage/zerotier.sh" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/zerotier.sh"
fi
if [ ! -f "/etc/storage/zerotier.sh" ] ; then
logger -t "【ZeroTier】" "下载失败，请稍后再试，或使用手动上传"
echo "下载失败，请稍后再试，或使用手动上传"
fi
if [ -f "/etc/storage/zerotier.sh" ] ; then
   logger -t "【ZeroTier】" "脚本下载完成，请打开恩山论坛帖子参照教程1.在参数设置-脚本-在路由器启动后执行里填入启动参数，填写你zerotier id"
   echo  "脚本下载完成，请打开恩山论坛帖子参照教程1.在参数设置-脚本-在路由器启动后执行里填入启动参数，填写你zerotier id"
   logger -t "【ZeroTier】" "2.在系统管理-控制台输入nvram set zerotier_id=你的zerotier id 命令一次"
   echo  "2.在系统管理-控制台输入nvram set zerotier_id=你的zerotier id 命令一次"
   logger -t "【ZeroTier】" "3.在系统管理-控制台输入/etc/storage/zerotier.sh start 命令手动启动" 
   echo "3.在系统管理-控制台输入/etc/storage/zerotier.sh start 命令手动启动"
fi
fi
