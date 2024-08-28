#Check for updates
CurrentVersion=$(cat /boot/lib/version)
wget -N https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/Version
NewVersion=$(cat /boot/lib/version)

if [[ "$CurrentVersion" != "$NewVersion" ]]
then
  echo Update is available...
  echo Updating....
  cd /boot/autostart.d
  wget -N https://raw.githubusercontent.com/nall-nifmcp/AutoSpeedTest10ZigConfig/main/SpeedTestConfig.sh
  chmod +x /boot/autostart.d/SpeedTestConfig.sh  
fi

