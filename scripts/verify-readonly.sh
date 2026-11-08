#!/usr/bin/env bash
# READ-ONLY pre-reboot checks. Usage: sudo ./verify-readonly.sh /path/to/SYSTEM /dev/DISK [/dev/DISK...]
H=$1; shift
for D in "$@"; do
  echo "=== $D"; sgdisk -v "$D" 2>&1 | tail -3; sgdisk -p "$D" 2>/dev/null | grep -Ei '4201|4202' && echo "!! LDM types remain"
  for P in $(lsblk -lnpo NAME,FSTYPE "$D" | awk '$2=="ntfs"{print $1}'); do echo "-- $P"; ntfsfix -n "$P" 2>&1 | tail -1; done
done
CS='\ControlSet001'
for k in BootExecute SetupExecute PendingFileRenameOperations; do echo "== $k"; hivexget "$H" "$CS\\Control\\Session Manager" "$k" 2>&1; done
for s in volmgr volmgrx partmgr disk stornvme storahci; do printf '%s Start=' $s; hivexget "$H" "$CS\\Services\\$s" Start 2>&1; done
hivexregedit --export "$H" "$CS\\Services" 2>/dev/null | grep -qi mda_ntdrv && echo "!! MDA_NTDRV reference remains" || echo "no MDA_NTDRV refs"
hivexregedit --export "$H" "$CS\\Services\\volmgrx" 2>/dev/null | grep -i PrimaryPackId && echo "!! PrimaryPackId remains"
