# Read-Only Verification Checklist Before Rebooting Windows

> Read-only checks of partition tables, NTFS, registry hive, drivers, and the ESP before each reboot attempt.

[← 06-fix-0x69-partition-gaps.md](06-fix-0x69-partition-gaps.md) · [Index](../README.md#table-of-contents) · [08-after-boot-cleanup.md →](08-after-boot-cleanup.md)

## Read-only verification checklist before rebooting

Run all of this **read-only** before every reboot attempt. See [`scripts/verify-readonly.sh`](../scripts/verify-readonly.sh).

- [ ] `sudo sgdisk -v /dev/DISK`: no problems. `sgdisk -p`: numbering has no gaps, no `4201`/`4202` types remain
- [ ] `sudo sfdisk -d /dev/sdX`: MBR `label-id` unchanged, type `7`, correct start
- [ ] `sudo ntfsfix -n /dev/PART` on every volume: no errors
- [ ] `ntfsresize --info --force --no-action` size ≤ partition size
- [ ] Hive sweep: `BootExecute` = `autocheck autochk *` only. `SetupExecute` empty or absent. **No** `PendingFileRenameOperations` pointing at removed tools
- [ ] No service key references `MDA_NTDRV`. Check the `Start` values of boot drivers: `volmgr`, `volmgrx`, `partmgr`, `disk`, `stornvme`, `storahci` should be `0`
- [ ] `volmgrx` has no `PrimaryPackId`, there's no `Services\MDA_NTDRV` key, and the rewritten GPT data-volume letters = `DMIO:ID:` + their partition GUIDs
- [ ] ESP: `EFI/Microsoft/Boot/bootmgfw.efi` and `EFI/Microsoft/Boot/BCD` exist (mount the ESP read-only)
- [ ] `Windows/System32/MDA_NTDRV.sys` renamed to `.disabled` (optional) and noted for deletion after boot

```bash
for k in BootExecute SetupExecute PendingFileRenameOperations; do
  echo "== $k"; hivexget ~/SYSTEM.work '\ControlSet001\Control\Session Manager' "$k" 2>&1
done
for s in volmgr volmgrx partmgr disk stornvme storahci; do
  printf '%s Start=' $s; hivexget ~/SYSTEM.work "\\ControlSet001\\Services\\$s" Start
done
hivexregedit --export ~/SYSTEM.work '\ControlSet001\Services' | grep -i mda_ntdrv || echo "no NIUBI driver refs"
```

---

[← 06-fix-0x69-partition-gaps.md](06-fix-0x69-partition-gaps.md) · [Index](../README.md#table-of-contents) · [08-after-boot-cleanup.md →](08-after-boot-cleanup.md)
