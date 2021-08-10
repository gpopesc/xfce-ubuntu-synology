# xfce-ubuntu-synology
xfce frontend based on ubuntu image, tested on Synology with docker
GitHub: https://github.com/gpopesc/xfce-ubuntu-synology

# Minimal installation in docker of a ubuntu container with Xfce desktop with sound (only in linux)

It use about 500Mb disk size and it needs about 350-450Mb RAM when running (more with firefox or chrome).
It has built in vnc server and noVNC for web access.

There is a full docker image with all apps preinstalled here: 

It has Chrome, Firefox, Palemoon, Putty, Image viewer, Mousepad text editor, Xarchiver and many plugins from XFCE desktop

Modify the password and the screen resolution in docker-compose. The default password is admin.
Map your ports as you wish. Default port for vnc connection is 5905 and for http port is 8087.
SHM added in docker compose or CLI in order to avoid errors on Firefox when running.
The image was tested on Synology DS218+, linux and windows .

Acces the container with a VNC client on port 5902 or simply http://server-ip:8088 in your browser.
Wait for container to startup about 1 minute, depending of your configuration.
Execute the script from Home folder: capslock_toggle.sh if the caps lock remain on or install a virtual keyboard ``` apt-get update && apt-get install onboard ```

You can add a browser inside from terminal, after succesfull container deployment:
```
apt-get update && apt-get install firefox
```

Use reverse proxy if you want to secure your connection. Create websocket on your reverse proxy settings in Synology.
![image](https://user-images.githubusercontent.com/11590919/124982716-b4741500-e03f-11eb-968d-99a0c4ae46f7.png)


You can build the image yourself with the apps you need or you download the minimal installation from docker hub.

# Installation: 

*Method 1: Easyest with docker-compose.yml :*

```
version: "3"
services:
  dev-ubu-host:
    image: gpopesc/xfce-ubuntu-xs
    container_name: xfce-ubuntu
#    build: .
    environment:
      - VNCPASS=$VNC               #VNC and root password
      - DISPLAY_WIDTH=$WIDTH
      - DISPLAY_HEIGHT=$HEIGHT
      - TZ=$TZ
      - UID=$UID
      - GID=$GID
      - USER_NAME=$USER_NAME      #comment or delete if you want run as root
      - USER_PASSWORD=$USER_PASS  #comment or delete if you want run as root
    ports:
      - $VNCPORT:5900   
      - $HTTPPORT:8000
    volumes:
      - ./data:/home/$USER_NAME
#      - $LOCAL_PATH:/home/$USER_NAME/share             # uncomment if want to mount additional share
#      - /run/user/$UID/pulse:/run/user/$UID/pulse:ro   # uncomment in linux if you want sound (not synology)
      - type: tmpfs
        target: /dev/shm
        tmpfs:
         size: 4000000000 # ~4gb
    restart: on-failure
```
Save .env.sample.txt from here(https://github.com/gpopesc/xfce-ubuntu-synology/blob/main/.env.sample.txt) and modify your variables then rename it to .env, next your docker-compose.yml file
Create a local folder "data", then "docker-compose up -d" from your ssh command prompt


*Method 2: build the image yourself and customize it according with your needs.*

```
 git clone https://github.com/gpopesc/xfce-ubuntu-synology.git
 cd xfce-ubuntu-synology
 docker-compose build --pull
 docker-compose up -d
 ```


Dockerfile has a lot optional apps, which are not installed by default.
Uncomment the corespondend lines if you want to install them.



*Method 3: install from docker CLI* - less recommended -
From your SSH client copy-paste and run following command (all rows, one time):

```
docker run -p 8088:8080 -p 5902:5900\
 -e VNCPASS=admin\
 -e DISPLAY_WIDTH=1200\
 -e DISPLAY_HEIGHT=720\
 -e TZ=Europe/Bucharest\
 -e UID=1026\
 -e GID=100\
 -e USER_NAME=your_user\
 -e USER_PASSWORD=youruser_pass\
 -v /volume1/docker/syno-ubuntu/data:/home \
 --shm-size 4g\
 --name syno-ubuntu\
 --restart on-failure\
 gpopesc/xfce-ubuntu-xs
```
Create local folder "syno-ubuntu/data" in your docker folder and map it in the command. Adjust full local path acordingly: "/volume1/docker/syno-ubuntu/data"
Replace default password and resolution with desired options.