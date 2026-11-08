#!/usr/bin/env bash
# Converts a GPT partition unique GUID into a MountedDevices "DMIO:ID:" REG_BINARY hex string.
# Usage: ./guid-to-mounteddevices.sh {PARTITION-GUID}
g=$(echo "$1" | tr -d '{}' | tr 'A-F' 'a-f')
IFS=- read a b c d e <<< "$g"
rev(){ echo "$1" | sed 's/../& /g' | awk '{for(i=NF;i>0;i--)printf "%s",$i}'; }
hex="444d494f3a49443a$(rev $a)$(rev $b)$(rev $c)$d$e"
echo "hex:$(echo $hex | sed 's/../&,/g; s/,$//')"
