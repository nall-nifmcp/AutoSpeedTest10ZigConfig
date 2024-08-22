mkdir -p /boot/lib/
FILE=/boot/lib/speedtest.sh
if [ -f "$FILE" ]; then
	echo "$FILE" exists
else
	cd /boot/lib
	echo  -e 'FILE=/boot/lib/speedtest.py\nif [ -f "$FILE" ]; then\necho "$FILE" exists\nelse\ncd /boot/lib\nwget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py\nchmod +x ./speedtest.py\nfi\npython3 /boot/lib/speedtest.py > /tmp/speedtest.log\n' >> ./speedtest.sh
	chmod +x ./speedtest.sh
fi

echo "00 12 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root

service cron stop
service cron start

sleep 30s

viewsharevar='"/tmp"'
grep -qxF "view.sharingFolders = $viewsharevar" /tmp/config/files/vmware/view-preferences || echo "view.sharingFolders = $viewsharevar" >> /tmp/config/files/vmware/view-preferences

sync
freeze
