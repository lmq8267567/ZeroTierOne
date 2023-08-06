#!/bin/bash
#copyright by hiboy
source /etc/storage/script/init.sh
PROG=/opt/bin/zerotier-one
PROGCLI=/opt/bin/zerotier-cli
PROGIDT=/opt/bin/zerotier-idtool
config_path="/etc/storage/zerotier-one"
PLANET="/etc/storage/zerotier-one/planet"
zeroid="$(nvram get zerotier_id)"
zerotier_renum=`nvram get zerotier_renum`
zerotier_renum=${zerotier_renum:-"0"}

if [ ! -z "$(echo $scriptfilepath | grep -v "/tmp/script/" | grep zerotier)" ]  && [ ! -s /tmp/script/_zerotier ]; then
	mkdir -p /tmp/script
	{ echo '#!/bin/bash' ; echo $scriptfilepath '"$@"' '&' ; } > /tmp/script/_zerotier
	chmod 777 /tmp/script/_zerotier
fi
zerotier_restart () {

relock="/var/lock/zerotier_restart.lock"
if [ "$1" = "o" ] ; then
	nvram set zerotier_renum="0"
	[ -f $relock ] && rm -f $relock
	return 0
fi
if [ "$1" = "x" ] ; then
	if [ -f $relock ] ; then
		logger -t "¡¾ZeroTier¡¿" "¶à´Î³¢ÊÔÆô¶¯Ê§°Ü£¬µÈ´ý¡¾"`cat $relock`"·ÖÖÓ¡¿ºó×Ô¶¯³¢ÊÔÖØÐÂÆô¶¯"
		exit 0
	fi
	zerotier_renum=${zerotier_renum:-"0"}
	zerotier_renum=`expr $zerotier_renum + 1`
	nvram set zerotier_renum="$zerotier_renum"
	if [ "$zerotier_renum" -gt "2" ] ; then
		I=19
		echo $I > $relock
		logger -t "¡¾ZeroTier¡¿" "¶à´Î³¢ÊÔÆô¶¯Ê§°Ü£¬µÈ´ý¡¾"`cat $relock`"·ÖÖÓ¡¿ºó×Ô¶¯³¢ÊÔÖØÐÂÆô¶¯"
		while [ $I -gt 0 ]; do
			I=$(($I - 1))
			echo $I > $relock
			sleep 60
			[ "$(nvram get zerotier_renum)" = "0" ] && exit 0
			[ $I -lt 0 ] && break
		done
		nvram set zerotier_renum="0"
	fi
	[ -f $relock ] && rm -f $relock
fi
nvram set zerotier_status=0
eval "$scriptfilepath &"
exit 0
}

zerotier_get_status () {

A_restart=`nvram get zerotier_status`
B_restart="1"
cut_B_re
if [ "$A_restart" != "$B_restart" ] ; then
	nvram set zerotier_status=$B_restart
	needed_restart=1
else
	needed_restart=0
fi
}


zerotier_check () {

zerotier_get_status
	if [ "$needed_restart" = "1" ] ; then
		zerotier_start
	else
		[ -z "`pidof zerotier-one`" ] && zerotier_restart
	fi
}

zerotier_keep  () {
[ ! -z "\`pidof zerotier-one\`" ] && logger -t "¡¾ZeroTier¡¿" "Æô¶¯³É¹¦"
if [ -s /tmp/script/_opt_script_check ]; then
SVC_PATH="$(which zerotier-one)"
[ ! -s "$SVC_PATH" ] && SVC_PATH="/opt/bin/zerotier-one"
[ ! -s "$SVC_PATH" ] && SVC_PATH="/tmp/zerotier-one/zerotier-one"
logger -t "¡¾ZeroTier¡¿" "ÊØ»¤½ø³ÌÆô¶¯"
sed -Ei '/¡¾ZeroTier¡¿|^$/d' /tmp/script/_opt_script_check
cat >> "/tmp/script/_opt_script_check" <<-OSC
	[ -z "\`pidof zerotier-one\`" ] || [ ! -s "$SVC_PATH" ] && nvram set zerotier_status=00 && logger -t "¡¾ZeroTier¡¿" "ÖØÐÂÆô¶¯" && eval "$scriptfilepath &" && sed -Ei '/¡¾ZeroTier¡¿|^$/d' /tmp/script/_opt_script_check # ¡¾ZeroTier¡¿
OSC
#return
fi

}

zero_ping() {
while [ "$(ifconfig | grep zt | awk '{print $1}')" = "" ]; do
		sleep 1
done
zt0=$(ifconfig | grep zt | awk '{print $1}')
while [ "$(ip route | grep "dev $zt0  proto static" | awk '{print $1}' | awk -F '/' '{print $1}')" = "" ]; do
sleep 1
done
ip00=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}')
[ -n "$ip00" ] && logger -t "¡¾ZeroTier¡¿" "zerotierÐéÄâ¾ÖÓòÍøÄÚÉè±¸£º$ip00 "
ip11=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==1 {print $1}'|cut -d. -f1,2,3)
ip22=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==2 {print $1}'|cut -d. -f1,2,3)
ip33=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==3 {print $1}'|cut -d. -f1,2,3)
ip44=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==4 {print $1}'|cut -d. -f1,2,3)
ip55=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==5 {print $1}'|cut -d. -f1,2,3)
sleep 20
[ -n "$ip11" ] && ping_zero1=$(ping -4 $ip11.1 -c 2 -w 4 -q)
[ -n "$ip22" ] && ping_zero2=$(ping -4 $ip22.1 -c 2 -w 4 -q)
[ -n "$ip33" ] && ping_zero3=$(ping -4 $ip33.1 -c 2 -w 4 -q)
[ -n "$ip44" ] && ping_zero4=$(ping -4 $ip44.1 -c 2 -w 4 -q)
[ -n "$ip55" ] && ping_zero5=$(ping -4 $ip55.1 -c 2 -w 4 -q)
[ -n "$ip11" ] && ping_time1=`echo $ping_zero1 | awk -F '/' '{print $4}'`
[ -n "$ip22" ] && ping_time2=`echo $ping_zero2 | awk -F '/' '{print $4}'`
[ -n "$ip33" ] && ping_time3=`echo $ping_zero3 | awk -F '/' '{print $4}'`
[ -n "$ip44" ] && ping_time4=`echo $ping_zero4 | awk -F '/' '{print $4}'`
[ -n "$ip55" ] && ping_time5=`echo $ping_zero5 | awk -F '/' '{print $4}'`
[ -n "$ip11" ] && ping_loss1=`echo $ping_zero1 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip22" ] && ping_loss2=`echo $ping_zero2 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip33" ] && ping_loss3=`echo $ping_zero3 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip44" ] && ping_loss4=`echo $ping_zero4 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip55" ] && ping_loss5=`echo $ping_zero5 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ ! -z "$ping_time1" ] && logger -t "¡¾ZeroTier¡¿" "½Úµã "$ip11".1£¬ÑÓ³Ù:$ping_time1 ms ¶ª°üÂÊ£º$ping_loss1 "
[ ! -z "$ping_time2" ] && logger -t "¡¾ZeroTier¡¿" "½Úµã "$ip22".1£¬ÑÓ³Ù:$ping_time2 ms ¶ª°üÂÊ£º$ping_loss2 "
[ ! -z "$ping_time3" ] && logger -t "¡¾ZeroTier¡¿" "½Úµã "$ip33".1£¬ÑÓ³Ù:$ping_time3 ms ¶ª°üÂÊ£º$ping_loss3 "
[ ! -z "$ping_time4" ] && logger -t "¡¾ZeroTier¡¿" "½Úµã "$ip44".1£¬ÑÓ³Ù:$ping_time4 ms ¶ª°üÂÊ£º$ping_loss4 "
[ ! -z "$ping_time5" ] && logger -t "¡¾ZeroTier¡¿" "½Úµã "$ip55".1£¬ÑÓ³Ù:$ping_time5 ms ¶ª°üÂÊ£º$ping_loss5 "

}

zerotier_close () {
del_rules
kill_ps "$scriptname keep"
sed -Ei '/¡¾ZeroTier¡¿|^$/d' /tmp/script/_opt_script_check
killall -9 zerotier-one
killall zerotier-one
kill_ps "/tmp/script/_zerotier"
kill_ps "_zerotier.sh"
kill_ps "$scriptname"
[ -z "`pidof zerotier-one`" ] && logger -t "¡¾ZeroTier¡¿" "½ø³ÌÒÑ¹Ø±Õ"
}

zerotier_start()  {
check_webui_yes
killall -9 zerotier-one
SVC_PATH="/opt/bin/zerotier-one"
SVC_PATH2="/opt/app/zerotier/zerotier.tar.gz"
[ ! -d "/opt/app/zerotier" ] && mkdir -p /opt/app/zerotier
[ ! -s "$SVC_PATH2" ] && [ -s "/etc/storage/zerotier-one/zerotier.tar.gz" ] && cp -rf /etc/storage/zerotier-one/zerotier.tar.gz /opt/app/zerotier/zerotier.tar.gz
zerosize=`check_disk_size /etc/storage`
curltest=`which curl`
if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
   tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
   [ -z "$tag" ] && tag="$( wget -T 5 -t 3 --output-document=-  https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
    else
    tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
    [ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
    [ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 -s https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
fi
[ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 --silent https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$(curl -k --silent "https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
if [ ! -s "$SVC_PATH" ] ; then
   logger -t "¡¾ZeroTier¡¿" "ÕÒ²»µ½$SVC_PATH,¿ªÊ¼°²×°"
   rm -rf "$PROG" "$PROGCLI" "$PROGIDT"
   if [ ! -s "$SVC_PATH2" ] || [ ! -s "$SVC_PATH2" ] ; then
       rm -rf /etc/storage/zerotier-one/MD5.txt
       if [ ! -z "$tag" ] ; then
           logger -t "¡¾ZeroTier¡¿" "»ñÈ¡µ½×îÐÂ°æ±¾zerotier_v$tag,¿ªÊ¼ÏÂÔØ"
           wgetcurl.sh "/etc/storage/zerotier-one/MD5.txt" "https://github.com/lmq8267/ZeroTierOne/releases/download/$tag/MD5.txt" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/$tag/tarMD5.txt"
           if [ "$zerosize" -lt 2 ];then
               logger -t "¡¾ZeroTier¡¿" "ÄúµÄÉè±¸/etc/storage¿Õ¼äÊ£Óà"$zerosize"M£¬²»×ã2M£¬½«ÏÂÔØ°²×°°üµ½ÄÚ´æ°²×°"
               [ "$zerosize" -gt 1 ] && logger -t "¡¾ZeroTier¡¿" "¿É³¢ÊÔÊÖ¶¯ÉÏ´«zerotier.tar.gzºÍMD5.txtµ½ÄÚ²¿´æ´¢/etc/storage/zerotier-one/Ä¿Â¼Àï"
               wgetcurl.sh "SVC_PATH2" "https://github.com/lmq8267/ZeroTierOne/releases/download/$tag/zerotier.tar.gz" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/$tag/zerotier.tar.gz"
               else
                logger -t "¡¾ZeroTier¡¿" "ÄúµÄÉè±¸/etc/storage¿Õ¼ä³ä×ã:"$zerosize"M£¬½«ÏÂÔØ°²×°°üµ½ÄÚ²¿´æ´¢"
                wgetcurl.sh "/etc/storage/zerotier-one/zerotier.tar.gz" "https://github.com/lmq8267/ZeroTierOne/releases/download/$tag/zerotier.tar.gz" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/$tag/zerotier.tar.gz"
           fi
       else
              logger -t "¡¾ZeroTier¡¿" "×îÐÂ°æ±¾»ñÈ¡Ê§°Ü£¬¿ªÊ¼ÏÂÔØ±¸ÓÃ³ÌÐòzerotier_v1.10.6"
              logger -t "¡¾ZeroTier¡¿" "Èô³öÏÖ·´¸´¸üÐÂÓÖÏÂÔØ£¬Çë¹Ø±Õ×Ô¶¯¸üÐÂ"
	      rm -rf /etc/storage/zerotier-one/MD5.txt
              wgetcurl.sh "/etc/storage/zerotier-one/MD5.txt" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.6/MD5.txt" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/1.10.6/tarMD5.txt"
              if [ "$zerosize" -lt 2 ];then
               logger -t "¡¾ZeroTier¡¿" "ÄúµÄÉè±¸/etc/storage¿Õ¼äÊ£Óà"$zerosize"M£¬²»×ã2M£¬½«ÏÂÔØ°²×°°üµ½ÄÚ´æ°²×°"
               [ "$zerosize" -gt 1 ] && logger -t "¡¾ZeroTier¡¿" "¿É³¢ÊÔÊÖ¶¯ÉÏ´«zerotier.tar.gzºÍMD5.txtµ½ÄÚ²¿´æ´¢/etc/storage/zerotier-one/Ä¿Â¼Àï"
               wgetcurl.sh "SVC_PATH2" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.6/zerotier.tar.gz" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/1.10.6/zerotier.tar.gz"
               else
                logger -t "¡¾ZeroTier¡¿" "ÄúµÄÉè±¸/etc/storage¿Õ¼ä³ä×ã:"$zerosize"M£¬½«ÏÂÔØ°²×°°üµ½ÄÚ²¿´æ´¢"
                wgetcurl.sh "/etc/storage/zerotier-one/zerotier.tar.gz" "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.6/zerotier.tar.gz" "https://fastly.jsdelivr.net/gh/lmq8267/zerotier@master/install/1.10.6/zerotier.tar.gz"
              fi
        fi
        [ ! -s "$SVC_PATH2" ] && [ -s "/etc/storage/zerotier-one/zerotier.tar.gz" ] && cp -rf /etc/storage/zerotier-one/zerotier.tar.gz "$SVC_PATH2"
    fi
     zeroMD5="$(cat /etc/storage/zerotier-one/MD5.txt)"
     [ ! -s "$SVC_PATH2" ] && [ -s "/etc/storage/zerotier-one/zerotier.tar.gz" ] && cp -rf /etc/storage/zerotier-one/zerotier.tar.gz "$SVC_PATH2"
     [ -s "$SVC_PATH2" ] && eval $(md5sum "$SVC_PATH2" | awk '{print "MD5_down="$1;}') && echo "$MD5_down"
     if [ ! -s "$SVC_PATH" ] ; then   
        if [ "$zeroMD5"x = "$MD5_down"x ] ; then
            logger -t "¡¾ZeroTier¡¿" "°²×°°üMD5Æ¥Åä£¬¿ªÊ¼½âÑ¹..."
	    rm -rf /tmp/var/zerotier-one
            tar -xzvf "$SVC_PATH2" -C /tmp/var
            [ -s /tmp/var/zerotier-one/zerotier-one ] && cp -rf /tmp/var/zerotier-one/* /opt/bin/
            sleep 5
	    rm -rf "/tmp/var/zerotier-one" "$SVC_PATH2"
            else
            logger -t "¡¾ZeroTier¡¿" "°²×°°üMD5²»Æ¥Åä£¬É¾³ý..."
            rm -rf "$SVC_PATH2"
            rm -rf /etc/storage/zerotier-one/zerotier.tar.gz
            rm -rf /tmp/zerotier.tar.gz
            zero_dl
        fi
     fi
fi
[ ! -s "$PROGCLI" ] && ln -sf "$PROG" "$PROGCLI"
[ ! -s "$PROGIDT" ] && ln -sf "$PROG" "$PROGIDT"
      chmod 777 "$PROG" "$PROGCLI" "$PROGIDT"
 if [ -s "$SVC_PATH" ] ; then
       zerotier_v=$($SVC_PATH -version | sed -n '1p')
       echo "$tag"
       echo "$zerotier_v"
       [ -z "$zerotier_v" ] && logger -t "¡¾ZeroTier¡¿" " ³ÌÐò²»ÍêÕû£¬É¾³ý£¬ÖØÐÂÏÂÔØ" && rm -rf "$SVC_PATH2" "/etc/storage/zerotier-one/zerotier.tar.gz" "/tmp/zerotier.tar.gz" "/tmp/var/zerotier-one" "$PROG" "$PROGCLI" "$PROGIDT" && zero_dl
       [ ! -z "$zerotier_v" ] && logger -t "¡¾ZeroTier¡¿" " $SVC_PATH °²×°³É¹¦£¬°æ±¾ºÅ:v$zerotier_v "
       if [ ! -z "$tag" ] && [ ! -z "$zerotier_v" ] ; then
          if [ "$tag"x != "$zerotier_v"x ] ; then
             cat /etc/storage/started_script.sh|grep zerotier_upgrade=y >/dev/null
	      if [ $? -eq 0 ] ; then
               logger -t "¡¾ZeroTier¡¿" "¼ì²âµ½×îÐÂ°æ±¾zerotier_v$tag,µ±Ç°°²×°°æ±¾zerotier_v$zerotier_v,ÒÑ¿ªÆô×Ô¶¯¸üÐÂ£¬¿ªÊ¼¸üÐÂ"
	       rm -rf /etc/storage/zerotier-one/MD5.txt
	       rm -rf /etc/storage/zerotier-one/zerotier.tar.gz
               rm -rf "$SVC_PATH2"
	        rm -rf "$PROG" "$PROGCLI" "$PROGIDT"
                zero_dl
                else
               logger -t "¡¾ZeroTier¡¿" "¼ì²âµ½×îÐÂ°æ±¾zerotier_v$tag,µ±Ç°°²×°°æ±¾zerotier_v$zerotier_v,Î´¿ªÆô×Ô¶¯¸üÐÂ,Ìø¹ý¸üÐÂ"
	      fi
           fi
       fi
  fi
start_instance 'zerotier'
}
    
start_instance() {
cfg="$(nvram get zerotier_id)"
echo $cfg
port=""
args=""
secret="$(cat /etc/storage/zerotier-one/identity.secret)"
moonid="$(nvram get zerotier_moonid)"
planet="$(nvram get zerotier_planet)"
[ ! -s "/etc/storage/zerotier-one/identity.secret" ] && secret="$(nvram get zerotier_secret)"
if [ ! -d "$config_path" ]; then
  mkdir -p $config_path
fi
mkdir -p $config_path/networks.d
if [ -n "$port" ]; then
   args="$args -p$port"
fi
if [ -z "$secret" ]; then
   [ ! -n "$cfg" ] && logger -t "¡¾ZeroTier¡¿" "ÎÞ·¨Æô¶¯£¬¼´½«ÍË³ö..." && logger -t "¡¾ZeroTier¡¿" "Î´»ñÈ¡µ½zerotier id£¬ÇëÈ·ÈÏÔÚ×Ô¶¨ÒåÉèÖÃ-½Å±¾-ÔÚÂ·ÓÉÆ÷Æô¶¯ºóÖ´ÐÐÀïÒÑÌîÐ´ºÃzerotier id" && logger -t "¡¾ZeroTier¡¿" "ÌîºÃºó£¬ÔÚÏµÍ³¹ÜÀí-¿ØÖÆÌ¨ÊäÈëÒ»´Învram set zerotier_id=ÄãµÄzerotier id" && logger -t "¡¾ZeroTier¡¿" "È»ºóÊÖ¶¯Æô¶¯£¬´ò¿ªttyd»òsshÊäÈëÒ»´Î zerotier start" && exit 1
   logger -t "¡¾ZeroTier¡¿" "Éè±¸ÃÜÔ¿Îª¿Õ£¬ÕýÔÚÉú³ÉÃÜÔ¿£¬ÇëÉÔºò..."
   sf="$config_path/identity.secret"
   pf="$config_path/identity.public"
   $PROGIDT generate "$sf" "$pf"  >/dev/null
   [ $? -ne 0 ] && return 1
   secret="$(cat $sf)"
   nvram set zerotier_secret="$secret"
   nvram commit
fi
if [ -n "$secret" ]; then
   logger -t "¡¾ZeroTier¡¿" "ÕÒµ½ÃÜÔ¿ÎÄ¼þ£¬ÕýÔÚÆô¶¯£¬ÇëÉÔºò..."
   echo "$secret" >$config_path/identity.secret
   $PROGIDT getpublic $config_path/identity.secret >$config_path/identity.public
fi
if [ -n "$planet"]; then
		logger -t "¡¾ZeroTier¡¿" "ÕÒµ½planet,ÕýÔÚÐ´Èë..."
		echo "$planet" >$config_path/planet.tmp
		base64 -d $config_path/planet.tmp >$config_path/planet
fi
if [ -f "$PLANET" ]; then
		if [ ! -s "$PLANET" ]; then
			echo "×Ô¶¨ÒåplanetÎÄ¼þÎª¿Õ,É¾³ý..."
			rm -f $config_path/planet
			rm -f $PLANET
			nvram set zerotier_planet=""
			nvram commit
		else
			logger -t "¡¾ZeroTier¡¿" "ÕÒµ½×Ô¶¨ÒåplanetÎÄ¼þ,¿ªÊ¼´´½¨..."
			planet="$(base64 $PLANET)"
			cp -f $PLANET $config_path/planet
			rm -f $PLANET
			nvram set zerotier_planet="$planet"
			nvram commit
		fi
fi
add_join $(nvram get zerotier_id)
$PROG $args $config_path >/dev/null 2>&1 &
rules

if [ -n "$moonid" ]; then
   $PROGCLI -D$config_path orbit $moonid $moonid
   logger -t "¡¾ZeroTier¡¿" "orbit moonid $moonid ok!"
fi
zeromoonip="$(nvram get zeromoonwan)"
moonip="$(nvram get zerotiermoon_ip)"
if [ "$zeromoonip" = "1" ] || [ -n "$moonip" ]; then
   logger -t "¡¾ZeroTier¡¿" "creat moon start!"
   creat_moon
   else
   remove_moon
fi
zerotier_get_status
eval "$scriptfilepath keep &"
zero_ping &
exit 0
}

add_join() {
		touch $config_path/networks.d/$(nvram get zerotier_id).conf
}

rules() {
	while [ "$(ifconfig | grep zt | awk '{print $1}')" = "" ]; do
		sleep 1
	done
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	logger -t "¡¾ZeroTier¡¿" "ÒÑ´´½¨ÐéÄâÍø¿¨ $zt0 "
	ip44=$(ifconfig $zt0  | grep "inet addr:" | awk '{print $2}' | awk -F '/' '{print $1}'| tr -d 'addr:' | tr -d ' ')
        ip66=$(ifconfig $zt0  | grep "inet6 addr:" | awk '{print $3}' | awk '{print $1,$2}'| tr -d 'addr' | tr -d ' ')
        [ -n "$ip66" ] && logger -t "¡¾ZeroTier¡¿" ""$zt0"_ipv6:$ip66"
        [ -n "$ip44" ] && logger -t "¡¾ZeroTier¡¿" ""$zt0"_ipv4:$ip44"
        [ -z "$ip44" ] && logger -t "¡¾ZeroTier¡¿" "Î´»ñÈ¡µ½zerotier ipÇëÇ°Íù¹ÙÍø¼ì²éÊÇ·ñ¹´Ñ¡´ËÂ·ÓÉ¼ÓÈëÍøÂç²¢·ÖÅäIP"
	del_rules
	iptables -I INPUT -i $zt0 -j ACCEPT
	iptables -I FORWARD -i $zt0 -o $zt0 -j ACCEPT
	iptables -I FORWARD -i $zt0 -j ACCEPT
	iptables -t nat -I POSTROUTING -o $zt0 -j MASQUERADE
	while [ "$(ip route | grep "dev $zt0  proto kernel" | awk '{print $1}')" = "" ]; do
	sleep 1
	done
	ip_segment="$(ip route | grep "dev $zt0  proto kernel" | awk '{print $1}')"
	iptables -t nat -A POSTROUTING -s $ip_segment -j MASQUERADE
	logger -t "¡¾ZeroTier¡¿" "ÆôÓÃZeroTier NAT"
        logger -t "¡¾ZeroTier¡¿" "ZeroTier¹ÙÍø£ºhttps://my.zerotier.com/network"
	####·ÃÎÊÉÏ¼¶Â·ÓÉÆäËûÉè±¸Ìí¼ÓÂ·ÓÉ¹æÔòÃüÁî##
	#ip route add $zero_ip via $zero_route dev $zt0
	#ÆäÖÐ$zero_ip¸ÄÎªzerotier¹ÙÍø·ÖÅäµÄip   $zero_route¸ÄÎªÄãÏëÒª·ÃÎÊµÄÉÏ¼¶Â·ÓÉÍø¶ÎÈç 192.168.30.0/24     $zt0¸ÄÎªÄãµÄzerotierÍø¿¨Ãû Èçztoj56Rop2
	#É¾³ýÃüÁîip route del $zero_ip via $zero_route dev $zt0
        
}

del_rules() {
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	ip_segment="$(ip route | grep "dev $zt0  proto" | awk '{print $1}')"
	iptables -D FORWARD -i $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -o $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i $zt0 -o $zt0 -j ACCEPT 2>/dev/null
	iptables -D INPUT -i $zt0 -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o $zt0 -j MASQUERADE 2>/dev/null
	iptables -t nat -D POSTROUTING -s $ip_segment -j MASQUERADE 2>/dev/null
}

#´´½¨moon½Úµã,zerotier²»ÔÙÖ§³Ö¶¯Ì¬ÓòÃû
creat_moon(){
moonip="$(nvram get zerotiermoon_ip)"
#¼ì²éÊÇ·ñºÏ·¨ip
regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
ckStep2=`echo $moonip | egrep $regex | wc -l`
logger -t "¡¾ZeroTier¡¿" "´î½¨ZeroTierµÄMoonÖÐ×ª·þÎñÆ÷£¬Éú³ÉmoonÅäÖÃÎÄ¼þ"
zeromoonip="$(nvram get zeromoonwan)"
if [ "$zeromoonip" = "1" ]; then
   #×Ô¶¯»ñÈ¡wanip
   ip_addr=`ifconfig -a ppp0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
   else
   ip_addr=$moonip
fi
logger -t "¡¾ZeroTier¡¿" "ZeroTier Moon·þÎñÆ÷ IP $ip_addr"
if [ -e $config_path/identity.public ]; then
   $PROGIDT initmoon $config_path/identity.public > $config_path/moon.json
   if `sed -i "s/\[\]/\[ \"$ip_addr\/9993\" \]/" $config_path/moon.json >/dev/null 2>/dev/null`; then
       logger -t "¡¾ZeroTier¡¿" "Éú³ÉmoonÅäÖÃÎÄ¼þ³É¹¦"
       else
       logger -t "¡¾ZeroTier¡¿" "Éú³ÉmoonÅäÖÃÎÄ¼þÊ§°Ü"
    fi
   logger -t "¡¾ZeroTier¡¿" "Éú³ÉÇ©ÃûÎÄ¼þ"
   cd $config_path
   pwd
   $PROGIDT genmoon $config_path/moon.json
   [ $? -ne 0 ] && return 1
   logger -t "¡¾ZeroTier¡¿" "´´½¨moons.dÎÄ¼þ¼Ð£¬²¢°ÑÇ©ÃûÎÄ¼þÒÆ¶¯µ½ÎÄ¼þ¼ÐÄÚ"
   if [ ! -d "$config_path/moons.d" ]; then
      mkdir -p $config_path/moons.d
   fi
   #·þÎñÆ÷¼ÓÈëmoon server
   mv $config_path/*.moon $config_path/moons.d/ >/dev/null 2>&1
   logger -t "¡¾ZeroTier¡¿" "moon½Úµã´´½¨Íê³É"
   zmoonid=`cat moon.json | awk -F "[id]" '/"id"/{print$0}'` >/dev/null 2>&1
   zmoonid=`echo $zmoonid | awk -F "[:]" '/"id"/{print$2}'` >/dev/null 2>&1
   zmoonid=`echo $zmoonid | tr -d '"|,'`
   nvram set zerotiermoon_id="$zmoonid"
   logger -t "¡¾ZeroTier¡¿" "ÒÑÉú³ÉMoon·þÎñÆ÷µÄID: $zmoonid"
   else
   logger -t "¡¾ZeroTier¡¿" "identity.public²»´æÔÚ"
 fi  
}
      
remove_moon(){
zmoonid="$(nvram get zerotiermoon_id)"
if [ ! -n "$zmoonid"]; then
  rm -f $config_path/moons.d/000000$zmoonid.moon
  rm -f $config_path/moon.json
  nvram set zerotiermoon_id=""
fi
}  

zero_dl(){
   sleep 2
   zerotier_start
}

case $ACTION in
start)
	zerotier_start
	;;
check)
	zerotier_check
	;;
stop)
	zerotier_close
	;;
keep)
	#zerotier_keep
	zerotier_keep
	;;

restart)
        zerotier_close
	zerotier_start
	;;

*)
	zerotier_check
	;;
esac

