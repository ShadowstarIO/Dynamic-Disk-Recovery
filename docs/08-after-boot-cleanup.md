# After Windows Boots: Drive Letters, Clock, NIUBI Leftovers, and chkdsk

> Restore drive letters, resync the clock, delete leftover driver files, and scan every volume.

[← 07-verify-before-reboot.md](07-verify-before-reboot.md) · [Index](../README.md#table-of-contents) · [09-troubleshooting-log.md →](09-troubleshooting-log.md)

## Step 6: After Windows boots

1. **Drive letters were reassigned.** In an admin PowerShell:
   ```powershell
   Get-Partition | Format-Table DiskNumber,PartitionNumber,DriveLetter,Size
   Set-Partition -DiskNumber 2 -PartitionNumber 2 -NewDriveLetter D   # three letters needed this here
   ```
2. **User-folder paths:** if Documents, Downloads, etc. were redirected to other drives, fix them under each folder's *Properties → Location*.
3. **Delete leftover NIUBI files:** `C:\Windows\System32\MDA_NTDRV.sys` (or `.sys.disabled`) and `C:\Windows\System32\nb-fre.exe`. Uninstall the app if it's still listed.
4. **Clock off by your UTC offset:** Linux wrote UTC to the hardware clock, and Windows reads it as local time. Fix:
   ```powershell
   w32tm /resync
   ```
5. **Check filesystems now** (online, read-only scan):
   ```powershell
   chkdsk C: /scan      # repeat for every volume
   ```
   On one data volume, `/scan` found a corrupt security-descriptor entry in `$Secure` and recommended a spot fix. **Recommended next step:** `chkdsk X: /spotfix`. It's short, but the volume goes offline while it runs. *(At the time of writing, this hadn't been run yet.)*
6. Confirm in Disk Management that every disk shows **Basic**.

---

[← 07-verify-before-reboot.md](07-verify-before-reboot.md) · [Index](../README.md#table-of-contents) · [09-troubleshooting-log.md →](09-troubleshooting-log.md)
