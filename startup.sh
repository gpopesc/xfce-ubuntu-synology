#!/bin/bash
exec >> /tmp/startup.log 2>&1

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
echo root:${VNCPASS} | sudo chpasswd
cp /tmp/config/index.html /opt/noVNC/index.html

if [ -n "${USER_NAME}" ]
 then
  echo "Running as user ${USER_NAME} with id ${UID} and groupid ${GID}"
  #set default root password
  groupadd -f -g ${GID} users
  groupmod -g ${GID} users
  useradd -u ${UID} -g ${GID} -m -p $(openssl passwd -1 ${USER_PASSWORD}) -s /bin/bash -G sudo ${USER_NAME}
  find /home/${USER_NAME} -path /home/${USER_NAME}/share -prune -o -exec chown ${UID}:${GID} {} \;
  usermod -a -G root ${USER_NAME} && usermod -a -G audio ${USER_NAME} && usermod -a -G users ${USER_NAME}
  export HOME=/home/${USER_NAME}
  echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S mkdir -p /home/${USER_NAME}/share
  echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S mkdir -p /home/${USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml
  echo ${USER_PASSWORD} | sudo -u ${USER_NAME} -S cp -nv /tmp/config/*.xml /home/${USER_NAME}/.config/xfce4/xfconf/xfce-perchannel-xml/
  cp /tmp/config/capslock_toggle.sh /home/${USER_NAME}/capslock_toggle.sh && chmod 777 /home/${USER_NAME}/capslock_toggle.sh
  sed -i "s|unix:/run/user/U_ID/pulse/native|unix:/run/user/$UID/pulse/native|" /tmp/config/pulse-client.conf && \
  cp -v /tmp/config/pulse-client.conf /etc/pulse/client.conf && \
  echo "cd /home/${USER_NAME}" >> ~/.bashrc
  if [ -e "~/.bashrc" ]
    then
  echo ".bashrc exist --> skipping"
    else
  echo "cd /home/${USER_NAME}" >> ~/.bashrc
  fi
  echo "===========> script finnished <============" && \
  sudo -u ${USER_NAME} startxfce4 & \
  #echo ${USER_PASSWORD} | sudo -u ${USER_NAME} xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true && \
 else
  echo "Running as root"
  mkdir -p /root/share
  mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
  cp -nv /tmp/config/*.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/
  cp /tmp/config/capslock_toggle.sh /home/${USER_NAME}/capslock_toggle.sh && chmod 700 /home/${USER_NAME}/capslock_toggle.sh 
  echo "===========> script finnished <============" && \
  startxfce4 & \
  #xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true && \
fi
rm -rf /tmp/config
echo "===========> Done <============"