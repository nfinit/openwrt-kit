#!/usr/bin/env bash
TTYDEV=$(getpl2303)
BAUDRATE=9600
TERMTYPE=dumb
clear
echo "Starting agetty on ${TTYDEV} at ${BAUDRATE} baud (terminal type: $TERMTYPE)
/usr/sbin/agetty -p BAUDRATE $TTYDEV $TERMTYPE
echo "[$(date)]: agetty terminated"
