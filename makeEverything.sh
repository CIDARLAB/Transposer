#!/bin/bash

#make executable: sudo chmod +x makeEverything.sh
#execute: ./makeEverything.sh

scriptVersion='2014.12.03'
useLog=true
defaultUser='pi'
gitUserEmail='ryan.jay.silva@gmail.com'
gitUsername='Ryan Silva'
ipAddress=$(ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

########################################################
echo ':: AutoBuild TweeColi v'$scriptVersion''
echo '   tail -f makeEverything.log to monitor install...'
set -e
if [ "$(id -u)" != "0" ]; then
  echo '  ERROR -> Root Required'
  exit 1
fi
if $useLog; then
  log=$(pwd)/makeEverything.log
  sudo -u $defaultUser touch makeEverything.log
else
  log=''
fi

#########################################################

function timer() {                                      # Timer block
  if [[ $# -eq 0 ]]; then
    echo $(date '+%s')
  else
    local stime=$1
    etime=$(date '+%s')

    if [[ -z "$stime" ]]; then stime=$etime; fi

    dt=$((etime-stime))
    ds=$((dt % 60))
    dm=$(((dt / 60) % 60))
    dh=$((dt / 3600))
    printf '%d:%02d:%02d elapsed' $dh $dm $ds
  fi
  }
startTime=$(timer)

#########################################################

echo ':: Update packages'
sudo apt-get --yes update >> $log
sudo apt-get --yes dist-upgrade >> $log
echo '   '$(timer $startTime)

#########################################################

echo ':: Install packages'
echo '   vim'
sudo apt-get --yes install vim >> $log
sudo cp /home/$defaultUser/Bioelectronics/.vimrc /home/$defaultUser/
echo '   minicom'
sudo apt-get --yes install minicom >> $log
sudo cp /home/$defaultUser/Bioelectronics/.bashrc /home/$defaultUser/
echo '   pip'
sudo apt-get --yes install python-pip >> $log
echo '   twython'
sudo pip install twython >> $log
echo '   '$(timer $startTime)

#########################################################

echo ':: configure git'
git config --global user.email $gitUserEmail
git config --global user.name $gitUsername
echo '   '$(timer $startTime)

#########################################################

echo ':: Atlas Scientific Setup'
echo '   rpi-serial-console install'
sudo wget https://raw.githubusercontent.com/lurch/rpi-serial-console/master/rpi-serial-console -O /usr/bin/rpi-serial-console && sudo chmod +x /usr/bin/rpi-serial-console >> $log
echo '   disable serial console'
sudo rpi-serial-console disable >> $log 
echo '   '$(timer $startTime)
echo 'Your ip address is '$ipAddress''
echo 'For the serial console to be disabled, you must restart the pi'
echo ':: Installed OKAY. Enjoy.'
