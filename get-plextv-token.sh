#!/bin/bash
# pms-tools
# get-plextv-token.sh - Plex Token Retriever

XPLEXPRODUCT="pms-tools-pmsupdate"
XPLEXVER="1.0"
XPLEXCLIENTID="pms-tools-pmsupdate-${RANDOM}"
CONTENTTYPE="application/x-www-form-urlencoded; charset=utf-8"

echo -en "\n"
read -p "Enter plex.tv username: " USERNAME
read -s -p "Enter plex.tv password: " PASSWORD
echo -e "\n"

PLEX_TOKEN=$(
curl -s -X POST "https://plex.tv/users/sign_in.json" \
     -H "X-Plex-Product: ${XPLEXPRODUCT}" \
     -H "X-Plex-Version: ${XPLEXVER}" \
     -H "X-Plex-Client-Identifier: ${XPLEXCLIENTID}" \
     -H "Content-Type: ${CONTENTTYPE}" \
     -d "user[login]=${USERNAME}" \
     -d "user[password]=${PASSWORD}" | python3 -c 'import sys, json; print(json.load(sys.stdin))["user"]["authentication_token"]')

echo -e "------\nToken: ${PLEX_TOKEN}\n------\n"
