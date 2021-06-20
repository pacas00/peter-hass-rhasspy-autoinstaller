#! /bin/bash

#Credit to Bob Copeland
#Source: https://bobcopeland.com/blog/2012/10/goto-in-bash/
# If the link ever goes down, theres two stack overflow links that i found along the way
#
#https://stackoverflow.com/a/31269848
#https://askubuntu.com/a/1070296

function goto
{
    label=$1
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

hello_world () {
   echo 'hello, world'
}

load_vars () {
	VARS=vars.sh
	if [ -f "$VARS" ]; then
		#echo "$VARS exists."
		source $VARS
#	else 
		#echo "$VARS does not exist."
	fi
}

save_vars () {
	echo "BASE=$BASE" > vars.sh
	echo "BASESP=$BASESP" >> vars.sh
	echo "RESP2MIC=$RESP2MIC" >> vars.sh
	echo "basestation=$basestation" >> vars.sh
	echo "LLAToken=$LLAToken" >> vars.sh
	chmod +x vars.sh
}

load_stage () {
	STAGE=-1
	if [ -f "stage.sh" ]; then
		echo "stage.sh exists."
		source stage.sh
		goto "stage$STAGE"
	else 
		echo "stage.sh does not exist."
	fi
}

save_stage () {
	echo "STAGE=$STAGE" > stage.sh
}

check_root () {
	if [ $USER == 'root' ]; then
		echo "Running as root"
	else 
		echo "This installer MUST be run as root. Run this again with sudo"
		exit;
	fi
}

my_function () {
  echo "some result"
  return 55
}


check_root

realuser=`who am i | awk '{print $1}'`
realuserhome=`eval echo "~$realuser"`
systemip=`hostname -I | awk '{print $1}'`
basestation=`hostname -I | awk '{print $1}'`
LLAToken=1234

raspberry=`cat /sys/firmware/devicetree/base/model | awk '{print $1}'`

#my_function
#echo $?
#hello_world

load_vars
load_stage

#clear
#echo $realuser

goto "stage0"

: stage0
STAGE=0
save_stage

BASE=0
BASESP=0
RESP2MIC=0

echo "Is this unit a Base Station"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) BASE=1; break;;
        No ) BASE=0; break;;
    esac
done


if [ "$BASE" = "1" ]; then
	echo "Is this Base Station also a Speaker"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) BASESP=1; break;;
			No ) BASESP=0; break;;
		esac
	done
fi

if [ "$BASE" = 0 ] || [ "$BASESP" = 1 ]; then

	echo "Is a Respeaker 2 Mic Hat attached to this Pi. Answer no if not / not a Pi. (Driver only works on Pi)"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) RESP2MIC=1; break;;
			No ) RESP2MIC=0; break;;
		esac
	done
fi






#TODO Network


echo 
echo Your IP Address is $systemip, If this is the basestation, please make this static and remember the ip for any speaker units.
echo
sleep 15

STAGE=1
save_vars
save_stage
: stage1

	echo 
	echo ---------------------
	echo Installing Dependencies
	echo ---------------------
	echo 

apt-get update

apt-get install -y git

if [ $BASE == 0 ] || [ $BASESP == 1]; then
	echo 
	echo ---------------------
	echo Installing PulseAudio
	echo ---------------------
	echo 
	apt-get install -y pulseaudio paprefs pavucontrol-qt

fi





mkdir -p /opt/PeterC_HA_AutoInstaller


STAGE=2
save_stage
: stage2

#Audio Drivers
	echo 
	echo ---------------------
	echo Installing Selected Audio Drivers
	echo ---------------------
	echo 

if [ "$RESP2MIC" = "1" ]; then

	echo 
	echo 
	echo Installing the Respeaker 2 Mic Hat Drivers will require a reboot.
	echo System will automatically restart
	echo 
	echo 
	read -p "Press enter to continue"
	
	git clone https://github.com/HinTak/seeed-voicecard
	cd seeed-voicecard
	STAGE=3
	save_stage
	
	source install.sh
	
	# Fix SystemD Service
	sed -i 's/alsa restore/alsa -f \/etc\/voicecard\/wm8960_asound.state restore/g' /lib/systemd/system/alsa-restore.service
	sed -i 's/alsa store/alsa -f \/etc\/voicecard\/wm8960_asound.state store/g' /lib/systemd/system/alsa-restore.service

	systemctl daemon-reload
	
	reboot now
	
fi


STAGE=3
save_stage
: stage3

	echo 
	echo ---------------------
	echo Network Configuration (TODO)
	echo ---------------------
	echo 

#Network


STAGE=4
save_stage
: stage4

	echo 
	echo ---------------------
	echo Installing Docker
	echo ---------------------
	echo 

curl -fsSL https://get.docker.com -o get-docker.sh
(bash get-docker.sh)

echo $realuser can use docker
usermod -aG docker $realuser


STAGE=5
save_stage
: stage5

#portainer
echo 
echo ---------------------
echo Installing Portainer
echo ---------------------
echo 

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

echo 
echo 
echo Please browse to http://$systemip:9000 and complete the Portainer Setup.
echo 
echo 
read -p "Press enter to continue"


STAGE=6
save_stage
: stage6

	echo 
	echo ---------------------
	echo Installing Default Configs
	echo ---------------------
	echo 

mkdir -p /opt/PeterC_HA_AutoInstaller



STAGE=7
save_stage
: stage7

#Home Assistant
if [ $BASE == 1 ]; then
	echo 
	echo ---------------------
	echo Installing Home Assistant
	echo ---------------------
	echo 
	
	haimg=homeassistant/home-assistant:stable
	
	if [ $raspberry == "Raspberry" ]; then	
		raspberry=`cat /sys/firmware/devicetree/base/model | awk '{print $3}'`	
		if [ $raspberry == "3" ]; then		
			haimg=homeassistant/raspberrypi3-homeassistant:stable		
		fi
		if [ $raspberry == "4" ]; then		
			haimg=homeassistant/raspberrypi4-homeassistant:stable		
		fi	
	fi
	echo $haimg

	mkdir -p /opt/PeterC_HA_AutoInstaller/homeassistant

	docker run --init -d \
	  --name homeassistant \
	  --restart=unless-stopped \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /opt/PeterC_HA_AutoInstaller/homeassistant:/config \
	  --network=host \
	  $haimg
	
	
	
	echo 
	echo 
	echo Please browse to http://$systemip:8123 and complete the Home Assistant Setup.
	echo 
	echo 
	read -p "Press enter to continue"
	
	#LLAToken
	echo 
	echo 
	echo Please create a Long Lived Access Token.
	echo
	echo If you are doing the setup on a device with a GUI, it is recommended you perform this step on device.
	echo Otherwise, you are going to have to manually type a long and case sensitive token in.
	echo 
	echo Click the user button in the bottom left of Home Assistant.
	echo Scroll down to Long-Lived Access Tokens. Click Create and name it.
	echo Copy down the token. It is case sensitive, and you will need to enter it shortly.
	echo 
	echo 
	read -p "Press enter to continue"
	
	read -p "Please enter the LLA Token: " LLAToken
	save_vars

fi

STAGE=8
save_stage
: stage8

if [ $BASE == 1 ]; then
	echo  >> /opt/PeterC_HA_AutoInstaller/homeassistant/configuration.yaml
	echo intent: >> /opt/PeterC_HA_AutoInstaller/homeassistant/configuration.yaml
	echo  >> /opt/PeterC_HA_AutoInstaller/homeassistant/configuration.yaml
	echo api: >> /opt/PeterC_HA_AutoInstaller/homeassistant/configuration.yaml
	echo  >> /opt/PeterC_HA_AutoInstaller/homeassistant/configuration.yaml
fi


STAGE=9
save_stage
: stage9

#Node Red - TODO
#I need to spend time investigating how to tie NR into the system
#Goals
#By Default, homeassistant handles all intents,
#Custom intents in ha that require external processing call into a single service, or NodeRed if more complete (Keep HA config simple
#TODO
# How to return from NodeRed to HA (Assumption: that i can listen for a web request, and just respond to it.


STAGE=10
save_stage
: stage10

#Rhasspy

mkdir -p /opt/PeterC_HA_AutoInstaller/rhasspy
mkdir -p /opt/PeterC_HA_AutoInstaller/rhasspyimg/

echo FROM rhasspy/rhasspy > /opt/PeterC_HA_AutoInstaller/rhasspyimg/Dockerfile
echo RUN apt-get install libpulse0 libasound2 libasound2-plugins >> /opt/PeterC_HA_AutoInstaller/rhasspyimg/Dockerfile

docker build -t="rhasspyimg" /opt/PeterC_HA_AutoInstaller/rhasspyimg/

profile_rhasspy=en_client

if [ $BASE == 1 ]; then
	profile_rhasspy=en_base
fi

if [ $BASESP == 1 ]; then
	profile_rhasspy=en_basesp
fi

chown -R $realuser /opt/PeterC_HA_AutoInstaller/rhasspy/
docker run -d -p 12101:12101 -p 12183:12183 \
      --name rhasspy \
      --restart unless-stopped \
      -v "/etc/alsa:/etc/alsa" \
      -v "/usr/share/alsa:/usr/share/alsa" \
      -v "$realuserhome/.config/pulse:/.config/pulse" \
      -v "/run/user/$UID/pulse/native:/run/user/$UID/pulse/native" \
      -v "/opt/PeterC_HA_AutoInstaller/rhasspy/profiles:/profiles" \
      -v "/etc/localtime:/etc/localtime:ro" \
      --env "PULSE_SERVER=unix:/run/user/$UID/pulse/native" \
      --user "$(id -u $realuser)" \
      rhasspyimg \
      --user-profiles /profiles \
      --profile $profile_rhasspy
chown -R $realuser /opt/PeterC_HA_AutoInstaller/rhasspy/


echo 
echo 
echo Please browse to http://$systemip:12101 and complete the Rhasspy Setup Setup.
echo 
echo 
read -p "Press enter to continue"

echo end of file