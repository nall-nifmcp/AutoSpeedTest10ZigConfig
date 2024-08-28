#Check for updates
CurrentVersion=$(cat /boot/lib/version)
wget -q https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/Version -O /boot/lib/version
NewVersion=$(cat /boot/lib/version)

if [[ "$CurrentVersion" != "$NewVersion" ]]
then
  echo Update is available...
  echo Updating....
  cd /boot/autostart.d
  wget -q https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/SpeedTestConfig.sh -O /boot/autostart.d/SpeedTestConfig.sh
  chmod +x /boot/autostart.d/SpeedTestConfig.sh  
  echo "Update Completed from $CurrentVersion to $NewVersion"
else
  echo "version $CurrentVersion is up-to-date"
fi

