#!/bin/sh

SVC_PATH="/etc/storage/zerotier.sh"
if [ ! -d "/etc/storage/zerotier-one" ] ; then
  mkdir -p /etc/storage/zerotier-one
fi
rm -rf /etc/storage/zerotier-one/zerotier_1.10.3-1_mipsel-3.4.ipk
if [ ! -e "$SVC_PATH" ] || [ ! -s "$SVC_PATH" ] ; then
       logger -t "【ZeroTier】" "开始从GitHub下载脚本，请稍候..."
       wgetcurl.sh "$SVC_PATH" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.4/zerotier.sh"  
   else
   logger -t "【ZeroTier】" "/etc/storage目录已有$SVC_PATH，文件重名,无法安装，请删除(控制台命令:rm -rf /etc/storage/zerotier.sh) 或重命名后重试"
   exit 1
fi

if [ -f "$SVC_PATH" ] ; then
       chmod 777 /etc/storage/zerotier.sh
    

zero_file="/tmp/zeroca.sh"
if [ ! -f "$zero_file" ] || [ ! -s "$zero_file" ] ; then
 cat > "$zero_file" <<-\EEE
#!/bin/sh

cat /etc/storage/started_script.sh|grep zerotiermoon >/dev/null
if [ $? -eq 0 ] ; then
logger -t "【ZeroTier】" "下载脚本成功，请前往自定义设置-脚本-在路由器启动后执行里按规则填写zerotier_id"
logger -t "【ZeroTier】" "填写完成后应用设置保存，再系统管理-控制台输入/etc/storage/zerotier.sh start"
esle
cat >> "/etc/storage/started_script.sh" <<-OSC        
  
#ZeroTier启动脚本
#填写网络ID，去掉最下方代码前的#，应用设置后，点击右上角重启一次即可或者控制台输入一次最下方那条代码也行
#填写你在zerotier官网创建的网络ID，填写格式如:nvram set zerotier_id=6cccb567v880adf8
nvram set zerotier_id=

#填写Moon服务器生成的ID，没有则不填，有把下方#去掉启用,填写格式如:=a56c826623
#nvram set zerotier_moonid=

#ZeroTier Moon服务器 IP，把下方#去掉启用,填写格式如=175.13.156.223
#nvram set zerotiermoon_ip=
#下方填=1将使用Wan口获得的IP作为服务器 IP（请确认Wan口为公网IP），把下方#去掉启用
#nvram set zeromoonwan=1 
       
#下方代码前#去掉则启用开机自启              
#/etc/storage/zerotier.sh start
  
OSC

EEE

       chmod 777 "$zero_file"
fi

if [ -f "$zero_file" ] ; then
    /tmp/zeroca.sh  
    logger -t "【ZeroTier】" "下载脚本成功，请前往自定义设置-脚本-在路由器启动后执行里按规则填写zerotier_id"
    logger -t "【ZeroTier】" "填写完成后应用设置保存，再系统管理-控制台输入/etc/storage/zerotier.sh start"
fi
else
rm -rf /etc/storage/zerotier.sh
logger -t "【ZeroTier】" "下载失败，当前网络无法访问GitHub，请重试或过段时间再下载"
fi
