# Offline Windows Registry Fixes: BootExecute, MDA_NTDRV, volmgrx PrimaryPackId, MountedDevices

> Repair the offline SYSTEM hive with hivex (Linux) and reg load (WinRE) so Windows stops looking for the old dynamic pack.

[← 04-convert-mbr.md](04-convert-mbr.md) · [Index](../README.md#table-of-contents) · [06-fix-0x69-partition-gaps.md →](06-fix-0x69-partition-gaps.md)

## Step 4: Repair the offline SYSTEM hive

Mount the Windows partition, copy the hive, edit the **copy**, check it, then put it back.

```bash
sudo mkdir -p /mnt/win
sudo mount -t ntfs-3g -o remove_hiberfile /dev/nvmeXn1pW /mnt/win   # only if needed; prefer ro first
H=/mnt/win/Windows/System32/config/SYSTEM
cp "$H" ~/SYSTEM.orig && cp "$H" ~/SYSTEM.work
```

Find the active control set (usually `ControlSet001`):

```bash
hivexget ~/SYSTEM.work '\Select' Current
```

### 4.1 Restore BootExecute
```bash
hivexget ~/SYSTEM.work '\ControlSet001\Control\Session Manager' BootExecute   # shows nb-fre
```
⚠️ Edits the working copy:
```bash
cat > /tmp/fix.reg <<'R'
Windows Registry Editor Version 5.00

[\ControlSet001\Control\Session Manager]
"BootExecute"=hex(7):61,00,75,00,74,00,6f,00,63,00,68,00,65,00,63,00,6b,00,20,00,61,00,75,00,74,00,6f,00,63,00,68,00,6b,00,20,00,2a,00,00,00,00,00
R
sudo hivexregedit --merge --prefix 'HKEY_LOCAL_MACHINE\SYSTEM' /mnt/win/Windows/System32/config/SYSTEM /tmp/fix.reg
```
(That hex is `autocheck autochk *` as a REG_MULTI_SZ. `hivexregedit` needs `libwin-hivex-perl`, and `hivexget` comes from `libhivex-bin`. Back up `SYSTEM` first, as shown above.) In the recovery, the merge was run directly on the mounted hive. Merging into a working copy and then copying it back (4.5) is the more cautious version of the same step. If your `.reg` uses `HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001...` paths, pass the matching `--prefix`.

### 4.2 Delete the `MDA_NTDRV` service key (done from WinRE)
NIUBI registered its driver as a service, `ControlSet001\Services\MDA_NTDRV` (Start = 3, manual). It was removed from the **WinRE Command Prompt** with the SYSTEM hive loaded offline. Back it up first:

```bat
copy <WinDrive>:\Windows\System32\config\SYSTEM <WinDrive>:\Windows\System32\config\SYSTEM-before-fix.hiv
reg load HKLM\OFFSYS <WinDrive>:\Windows\System32\config\SYSTEM
reg query HKLM\OFFSYS /s /f MDA_NTDRV
```
⚠️ **WRITES TO THE HIVE**
```bat
reg delete HKLM\OFFSYS\ControlSet001\Services\MDA_NTDRV /f
```
(Keep the hive loaded for 4.3, then `reg unload HKLM\OFFSYS`.) A later check from Ubuntu found no remaining `MDA_NTDRV` key because it had already been deleted. The driver file `MDA_NTDRV.sys` was renamed to `.sys.disabled` and deleted after boot.

### 4.3 Delete volmgrx PrimaryPackId (done from WinRE)
`PrimaryPackId` is a value **directly under** `ControlSet001\Services\volmgrx`. It points Windows at the dynamic disk pack, which no longer exists. With the hive still loaded as in 4.2:

```bat
reg query HKLM\OFFSYS\ControlSet001\Services\volmgrx /s
```
⚠️ **WRITES TO THE HIVE**
```bat
reg delete HKLM\OFFSYS\ControlSet001\Services\volmgrx /v PrimaryPackId /f
reg unload HKLM\OFFSYS
```

### 4.4 Rewrite stale MountedDevices entries
`\MountedDevices` maps drive letters (`\DosDevices\C:`) and volume GUIDs to disks. Entries made while the disks were dynamic hold data meaning *LDM volume X*, which no longer exists. For **GPT** volumes the basic-disk format is:

```
"DMIO:ID:" (8 ASCII bytes: 44 4d 49 4f 3a 49 44 3a) + the 16-byte partition unique GUID in mixed-endian (on-disk) order
```

Get each partition's unique GUID:
```bash
sudo sgdisk -i W /dev/nvmeXn1     # "Partition unique GUID: {PARTITION-GUID}"
```

GUID `AABBCCDD-EEFF-GGHH-IIJJ-KKLLMMNNOOPP` → bytes `DD CC BB AA FF EE HH GG II JJ KK LL MM NN OO PP`. The first three groups are byte-reversed and the last two are kept as they are. See [`scripts/guid-to-mounteddevices.sh`](../scripts/guid-to-mounteddevices.sh). ⚠️ Edits the working copy:

```
[\MountedDevices]
"\\DosDevices\\E:"=hex:44,4d,49,4f,3a,49,44,3a,<16 GUID bytes>
```

**What was done here:** five stale `\DosDevices\X:` entries for the **GPT data volumes** were rewritten to `DMIO:ID:` + GUID, and two stale letters were deleted. **C: and the MBR volumes were left as they were.** Even so, Windows reassigned three letters after boot, which were fixed with `Set-Partition` ([after-boot cleanup](08-after-boot-cleanup.md)).

### 4.5 Check and write back
```bash
hivexregedit --export ~/SYSTEM.work '\ControlSet001\Control\Session Manager' | grep -i -A2 BootExecute
```
⚠️ **WRITES TO DISK**
```bash
sudo cp ~/SYSTEM.work /mnt/win/Windows/System32/config/SYSTEM
sync && sudo umount /mnt/win
```

---

[← 04-convert-mbr.md](04-convert-mbr.md) · [Index](../README.md#table-of-contents) · [06-fix-0x69-partition-gaps.md →](06-fix-0x69-partition-gaps.md)
