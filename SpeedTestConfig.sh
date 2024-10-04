#This script will setup a routine speedtest on a 10Zig Full Linux thin client and offload the results to passthrough the VDI session using Client Drive Redirection to be picked up and processed later by internal processes. 
#Note, this script will need to be deployed into the /boot/autostart.d directory of the 10zig so that it runs during boot. The speed test must be ran using crontabs as outlined here, it will fail if performed during the boot process because the network devices are not yet loaded.

#Creates directory for main scripts to be stored if it does not exist.
mkdir -p /boot/lib/

##Version 1.0.5
Version="1.0.5"
#Sets version of application, changing this value will cause the application on the endpoint to update automaticaly. 
echo $Version > /boot/lib/version

#Variable for Updater script
AutoUpdate=/boot/lib/Updater.sh
#Checks if Updater script exists, if not downloads it.
if [ -f "$AutoUpdate" ]; then
	echo "$AutoUpdate" exists
else
	cd /boot/lib
 	wget https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/Updater.sh
	chmod +x ./Updater.sh
fi

#Variable for Speedtest.sh file
FILE=/boot/lib/speedtest.sh
#Checks if speedtest.sh file exists, if not create it here
if [ -f "$FILE" ]; then
	echo "$FILE" exists
else
#This uses echo to write the speedtest.sh script if it does not exist. 
#Inside this "sub" script, it will also ensure the python speedtest utility is available and if not, download it. 
	cd /boot/lib
	echo  -e 'FILE=/boot/lib/speedtest.py\nif [ -f "$FILE" ]; then\necho "$FILE" exists\nelse\ncd /boot/lib\nwget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py\nchmod +x ./speedtest.py\nfi\npython3 /boot/lib/speedtest.py > /tmp/speedtest.log\n' >> ./speedtest.sh
	chmod +x ./speedtest.sh
fi

#sets the crontab schedules jobs to run the internet speed test on a routine.
echo "0 */2 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "55 7 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "15 8 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root
echo "30 8 * * * /boot/lib/speedtest.sh" | tee -a /var/spool/cron/crontabs/root

#sets auto-update schedule
echo "30 10 * * * /boot/lib/Updater.sh" | tee -a /var/spool/cron/crontabs/root

#restarts cron service to apply the new schedules.
service cron stop
service cron start


mkdir -p /tmp/config/files/vmware
CONFIGFILE=/tmp/config/files/vmware/view-preferences
#This part ensures the config file gets modified even if the application has not yet been launched for the first time. 
if [ -f "$CONFIGFILE" ]; then
	echo "$CONFIGFILE" exists
else
	touch $CONFIGFILE

fi

#local directory to mount through the VDI session.
viewsharevar='"/tmp"'
#Modifies the vmware client config file to mount the /tmp directory through the VDI session so the speedtest.log file can be accessed internally. Mounts as Z: by default on Windows.
#This can be hidden from the end user by modifying the registry and hiding the drive letter Z:.
grep -qxF "view.sharingFolders = $viewsharevar" /tmp/config/files/vmware/view-preferences || echo "view.sharingFolders = $viewsharevar" >> /tmp/config/files/vmware/view-preferences

#unsure what this does, but it was recommended by 10Zig to run after making changes to the filesystem. 
sync
freeze
