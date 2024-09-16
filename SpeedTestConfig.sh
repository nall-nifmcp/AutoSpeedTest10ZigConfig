mkdir -p /boot/lib/

##Version 1.0.5
Version="1.0.5"
echo $Version > /boot/lib/version

AutoUpdate=/boot/lib/Updater.sh
if [ -f "$AutoUpdate" ]; then
	echo "$AutoUpdate" exists
else
	cd /boot/lib
 	wget https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/Updater.sh
	chmod +x ./Updater.sh
fi

FILE=/boot/lib/speedtest.sh
if [ -f "$FILE" ]; then
	echo "$FILE" exists
else
	cd /boot/lib
	echo  -e 'FILE=/boot/lib/speedtest.py\nif [ -f "$FILE" ]; then\necho "$FILE" exists\nelse\ncd /boot/lib\nwget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py\nchmod +x ./speedtest.py\nfi\npython3 /boot/lib/speedtest.py > /tmp/speedtest.log\n' >> ./speedtest.sh
	chmod +x ./speedtest.sh
fi

echo "0 */2 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "30 10 * * * /boot/lib/Updater.sh" | tee -a /var/spool/cron/crontabs/root

echo "55 7 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "15 8 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "30 8 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root

service cron stop
service cron start
mkdir -p /tmp/config/files/vmware
CONFIGFILE=/tmp/config/files/vmware/view-preferences
if [ -f "$CONFIGFILE" ]; then
	echo "$CONFIGFILE" exists
else
	touch $CONFIGFILE

fi

viewsharevar='"/tmp"'
grep -qxF "view.sharingFolders = $viewsharevar" /tmp/config/files/vmware/view-preferences || echo "view.sharingFolders = $viewsharevar" >> /tmp/config/files/vmware/view-preferences

sync
freeze
