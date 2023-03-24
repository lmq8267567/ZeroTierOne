#!/bin/sh
logger -t "【ZeroTier】" "脚本下载完成，开始配置zerotier启动参数，自定义设置-脚本-在路由器启动后执行"
cat /etc/storage/started_script.sh|grep zerotier_id >/dev/null
if [ $? -eq 0 ] ; then
   logger -t "【ZeroTier】" "检测到自定义设置-脚本-路由器启动后执行已有相关参数，无法自动填入"
   url="https://www.right.com.cn/forum/thread-8274848-1-1.html"
   logger -t "【ZeroTier】" "请打开$url 参照教程手动填入启动参数"
   else
cat >> "/etc/storage/started_script.sh" <<-OSC
###############zerotier启动参数######################
#填写你在zerotier官网创建的网络ID，填写格式如:nvram set zerotier_id=6cccb567v880adf8
nvram set zerotier_id=

#填写Moon服务器生成的ID，没有则不填，填写格式如:=a56c826623
nvram set zerotier_moonid=

#ZeroTier Moon服务器 IP，必须公网IP,填写格式如=175.13.156.223
nvram set zerotiermoon_ip=

#下方填=1将使用Wan口获得的IP作为服务器 IP（请确认Wan口为公网IP）
nvram set zeromoonwan=

#zerotier自动更新版本,留空不启用，启用填=y
zerotier_upgrade=

#启用开机自启              
/etc/storage/zerotier.sh start

####################################################

OSC

fi

plb=$(find / -name "identity.public")
plb1=$(find / -name "authtoken.secret")
plb2=$(find / -name "identity.secret")
[ ! -d /etc/storage/zerotier-one ] && mkdir -p /etc/storage/zerotier-one
[ -s $plb ] && [ ! -s /etc/storage/zerotier-one/identity.public ] && cp -f $plb /etc/storage/zerotier-one/identity.public
[ -s $plb1 ] && [ ! -s /etc/storage/zerotier-one/authtoken.secret ] && cp -f $plb1 /etc/storage/zerotier-one/authtoken.secret
[ -s $plb2 ] && [ ! -s /etc/storage/zerotier-one/identity.secret ] && cp -f $plb2 /etc/storage/zerotier-one/identity.secret

zerotier_id="$(nvram get zerotier_id)"
if [ -n "$zerotier_id" ]; then
/etc/storage/zerotier.sh start
logger -t "【ZeroTier】" "开始启动，其他功能请在-自定义设置-脚本-在路由器启动后执行里填写"
else
    if [ -s /etc/storage/zerotier-one/identity.public ] &&  [ -s /etc/storage/zerotier-one/authtoken.secret ] && [ -s /etc/storage/zerotier-one/identity.secret ]; then
       logger -t "【ZeroTier】" "开始启动，其他功能请在-自定义设置-脚本-在路由器启动后执行里填写"
       /etc/storage/zerotier.sh start
   else
      logger -t "【ZeroTier】" "系统未发现zerotier_id,请在自定义设置-脚本-在路由器启动后执行里填写"
      logger -t "【ZeroTier】" "填好后，在系统管理-控制台输入一次nvram set zerotier_id=你的zerotier id"
     logger -t "【ZeroTier】" "然后手动启动，在系统管理-控制台输入一次 /etc/storage/zerotier.sh start "
    fi
fi
