#This script will setup a routine speedtest on a 10Zig Full Linux thin client and offload the results to passthrough the VDI session using Client Drive Redirection to be picked up and processed later by internal processes. 
#Note, this script will need to be deployed into the /boot/autostart.d directory of the 10zig so that it runs during boot. The speed test must be ran using crontabs as outlined here, it will fail if performed during the boot process because the network devices are not yet loaded.

#Creates directory for main scripts to be stored if it does not exist.
mkdir -p /boot/lib/

##Version 1.0.6
Version="1.0.6"
#Sets version of application, changing this value will cause the application on the endpoint to update automaticaly. The value in the Version file must also be updated on the git repository.  
echo $Version > /boot/lib/version

#Removing speedtest.sh file to replace python script with speedtestcli from ookla on versions 1.0.5 and lower
rm /boot/lib/speedtest.sh
#Removing speedtest.py used in version 1.0.5 and lower
rm /boot/lib/speedtest.py
#Removing Updater script used in version 1.0.5 and lower, Updater now runs config script after an update is recieved. 
rm /boot/lib/Updater.sh

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
#Inside this "sub" script, it will also ensure the speedtest utility is available and if not, download it. 
	cd /boot/lib
	echo -e 'SPEEDTESTCLI=/boot/lib/speedtest\nif [ -f "$SPEEDTESTCLI" ]; then\n echo "$SPEEDTESTCLI" exists\nelse\nwget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz\n tar -xvzf ookla-speedtest-1.2.0-linux-x86_64.tgz\n rm ./ookla-speedtest-1.2.0-linux-x86_64.tgz\n rm ./speedtest.md\nfi\n/boot/lib/speedtest --accept-license > /tmp/speedtest.log\n' >> ./speedtest.sh
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
