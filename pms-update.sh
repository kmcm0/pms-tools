#!/bin/bash
# pms-tools
# pms-update.sh - Plex Media Server Updater

if [ $(id -u) != 0 ]; then
        echo "This must be run as root."
        exit 1
fi

# User settings
#BUILD="<BUILD>"                    # linux-x86_64 for 64 bit, linux-x86 for 32 bit. linux-aarch64 for ARMv8, linux-armv7hf_neon for ARMv7
#DISTRO="<DISTRO>"                  # debian for .deb distros, redhat for rpm distros
#PLEX_TOKEN="<TOKEN>"               # Insert Plex pass token here, or use "none"

# (optional) source rc file for settings
if [ -f pms-update.rc ]; then
	. pms-update.rc
fi

if [[ ${DISTRO} == "debian" ]]; then
	CURRENT_VER=$(dpkg -l plexmediaserver|grep plexmediaserver|awk '{print $3}')
elif [[ ${DISTRO} == "redhat" ]]; then
	CURRENT_VER=$(rpm -q plexmediaserver|sed 's/plexmediaserver-//'|sed 's/.x86_64//')
else
	echo "$0 not configured. exiting."; exit 1
fi

if [[ ${PLEX_TOKEN} != "none" ]]; then
	LATEST_VER=$(curl -s -X GET "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=${PLEX_TOKEN}" | python -c 'import sys, json; print json.load(sys.stdin)["computer"]["Linux"]["version"]')
	DOWNLOAD_URL="https://plex.tv/downloads/latest/5?channel=8&build=${BUILD}&distro=${DISTRO}&X-Plex-Token=${PLEX_TOKEN}"
else
	LATEST_VER=$(curl -s -X GET "https://plex.tv/api/downloads/5.json" | python -c 'import sys, json; print json.load(sys.stdin)["computer"]["Linux"]["version"]')
	DOWNLOAD_URL="https://plex.tv/downloads/latest/5?build=${BUILD}&distro=${DISTRO}"
fi

cd /tmp
if [[ $CURRENT_VER != $LATEST_VER ]]; then
	if [[ ${DISTRO} ==  "debian" ]]; then
        	wget -O plexdl.deb $DOWNLOAD_URL
        	dpkg -i plexdl.deb
        	rm plexdl.deb
	elif [[ ${DISTRO} == "redhat" ]]; then
		wget -O plexdl.rpm $DOWNLOAD_URL
 		yum install -y plexdl.rpm
 		rm plexdl.rpm
	else
		exit 1
	fi
else
	echo "Not Updated, You have the current version."
fi

