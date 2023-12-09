#!/bin/sh
 
# /etc/show_wifi_clients.sh
# Shows MAC, IP address and any hostname info for all connected wifi devices
# written for openwrt 12.09 Attitude Adjustment

INTERFACES=`iwinfo | grep ESSID | cut -f 1 -s -d" "`

# header strings
INTERFACE_HEADER="INTERFACE"
SSID_HEADER="SSID"
MAC_HEADER="MAC ADDRESS"
IP_HEADER="IP ADDRESS"
HOSTNAME_HEADER="HOSTNAME"

# default settings
SHOW_HEADER=1 # --no-header
SHOW_TABLE=1  # --no-table
SHOW_COUNT=1  # --no-count
ABRIDGE=0     # --abridge

# parse arguments                                                  
while [ $# -gt 0 ]; do                                               
  if [[ "$1" = "--no-header" ]]; then 
    SHOW_HEADER=0
  elif [[ "$1" = "--no-table" ]]; then
    SHOW_HEADER=0
    SHOW_TABLE=0
  elif [[ "$1" = "--abridge" ]]; then
    ABRIDGE=1
  elif [[ "$1" = "--no-count" ]]; then
    SHOW_COUNT=0
  fi
  shift
done  

# get the longest string lengths for everything in /tmp/dhcp.leases

MAX_INTERFACE_LENGTH="${#INTERFACE_HEADER}"
MAX_SSID_LENGTH="${#SSID_HEADER}"
MAX_HOSTNAME_LENGTH="${#HOSTNAME_HEADER}"
for INTERFACE in $INTERFACES; do
  SSID=`iwinfo | grep ${INTERFACE} | cut -d '"' -f2`
  INTERFACE_LENGTH="${#INTERFACE}"
  if [ "$INTERFACE_LENGTH" -gt "$MAX_INTERFACE_LENGTH" ]; then
    MAX_INTERFACE_LENGTH="$INTERFACE_LENGTH"
  fi
  SSID_LENGTH="${#SSID}"
  if [ "$SSID_LENGTH" -gt "$MAX_SSID_LENGTH" ]; then
    MAX_SSID_LENGTH="$SSID_LENGTH"
  fi
  MACS=`iwinfo $INTERFACE assoclist | grep dBm | cut -f 1 -s -d" "`
  for MAC in $MACS; do
    HOSTNAME=`cat /tmp/dhcp.leases | cut -f 2,3,4 -s -d" " | grep -i $MAC | cut -f 3 -s -d" "`
    HOSTNAME_LENGTH="${#HOSTNAME}"
    if [ "$HOSTNAME_LENGTH" -gt "$MAX_HOSTNAME_LENGTH" ]; then
      MAX_HOSTNAME_LENGTH="$HOSTNAME_LENGTH"
    fi
  done
done

# print client table header
if [[ "$SHOW_HEADER" -eq "1" ]]; then
  [[ "$ABRIDGE" -eq "0" ]] && printf "%-${MAX_INTERFACE_LENGTH}s " "$INTERFACE_HEADER"
  printf "%-${MAX_SSID_LENGTH}s " "$SSID_HEADER"
  [[ "$ABRIDGE" -eq "0" ]] && printf "%-17s " "$MAC_HEADER"
  printf "%-14s " "$IP_HEADER"
  printf "%-${MAX_HOSTNAME_LENGTH}s " "$HOSTNAME_HEADER"
  printf "\n"
fi

# print client table data
CLIENT_COUNT=0
for INTERFACE in $INTERFACES; do
  SSID=`iwinfo | grep ${INTERFACE} | cut -d '"' -f2`
  MACS=`iwinfo $INTERFACE assoclist | grep dBm | cut -f 1 -s -d" "`
  for MAC in $MACS; do
    if [[ "$SHOW_TABLE" -eq "1" ]]; then
      IP=`cat /tmp/dhcp.leases | cut -f 2,3,4 -s -d" " | grep -i $MAC | cut -f 2 -s -d" "`
      if [[ -z "${IP}" ]]; then
        IP="n/a"
      fi
      HOSTNAME=`cat /tmp/dhcp.leases | cut -f 2,3,4 -s -d" " | grep -i $MAC | cut -f 3 -s -d" "`
      if [[ "${HOSTNAME}" == "*" || -z "${HOSTNAME}" ]]; then
        HOSTNAME="unknown"
      fi
      [[ "$ABRIDGE" -eq "0" ]] && printf "%-${MAX_INTERFACE_LENGTH}s " "$INTERFACE"
      printf "%-${MAX_SSID_LENGTH}s " "$SSID"
      [[ "$ABRIDGE" -eq "0" ]] && printf "%-17s " "$MAC"
      printf "%-14s " "$IP"
      printf "%-${MAX_HOSTNAME_LENGTH}s " "$HOSTNAME"
      printf "\n"
    fi
    CLIENT_COUNT=`expr ${CLIENT_COUNT} + 1`
  done
done
[[ "$SHOW_COUNT" -eq "1" ]] && echo "${CLIENT_COUNT} wireless client(s) connected"
