#!/bin/bash
LOG_LOCATION=/tmp/
exec >> $LOG_LOCATION/mylogfile.log 2>&1

echo 'deb http://download.opensuse.org/repositories/home:/Alexx2000/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/home:Alexx2000.list
curl -fsSL https://download.opensuse.org/repositories/home:Alexx2000/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Alexx2000.gpg > /dev/null

wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list

#adjust chrome shortcut for running
if [ -e "/usr/share/applications/google-chrome.desktop" ]
 then
  sed -i 's|Exec=/usr/bin/google-chrome-stable %U|Exec=/usr/bin/google-chrome-stable %U --no-sandbox|g' /usr/share/applications/google-chrome.desktop
 else
  echo "No Chrome installed"
fi

mkdir /tmp/.ICE-unix && chmod 1777 /tmp/.ICE-unix
echo "root pass"
echo root:${VNCPASS} | sudo chpasswd
#chmod 777 /usr/share/plank/themes/Default/dock.theme

if [ -n "${USER_NAME}" ]
 then
  echo "Running as user ${USER_NAME}"
  #set default root password
  useradd -m -p $(openssl passwd -1 ${USER_PASSWORD}) -s /bin/bash -G sudo ${USER_NAME}
  sudo usermod -a -G root ${USER_NAME}
  export HOME=/home/${USER_NAME}
  echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S mkdir -p /home/${USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml
  echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S cp /tmp/*.xml /home/${USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml/
  cp /root/capslock_toggle.sh /home/${USER_NAME}/capslock_toggle.sh && chmod 777 /home/${USER_NAME}/capslock_toggle.sh
  #echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S chown ${USER_NAME}:0 /home/${USER_NAME}/capslock_toggle.sh
  echo "cd /home/${USER_NAME}" >> ~/.bashrc
  sudo -u ${USER_NAME} startxfce4 & \
  sudo -u ${USER_NAME} crontab -l ; echo "* * * * * /usr/bin/mousepad" | crontab && \
  cron -f &
  #killall plank && sleep 10 && sudo -u ${USER_NAME} plank &
  #echo "===========> before sleep <============" && sleep 60 && \
  #echo ${USER_PASSWORD} | sudo -u ${USER_NAME} xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true && \
  #echo "===========> script finnished <============"
 else
  echo "Running as root"
  mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
  cp /tmp/*.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/
  nohup startxfce4 &>/dev/null & \
  #killall plank && sleep 10 && plank &
  #allow bash script running from thunar
  #echo "===========> before sleep <============" && sleep 60 && \
  #xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true && \
  #echo "===========> script finnished <============"
fi
