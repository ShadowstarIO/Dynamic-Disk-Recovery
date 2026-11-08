# Troubleshooting Log: Why Each Dynamic Disk Fix Was Tried

> Each observation, the reasoning behind it, the action taken, and the result, including what didn't help.

[← 08-after-boot-cleanup.md](08-after-boot-cleanup.md) · [Index](../README.md#table-of-contents) · [10-what-not-to-do.md →](10-what-not-to-do.md)

## Troubleshooting log: why each fix was tried

| # | Observation | Reasoning | Action | Result |
|---|---|---|---|---|
| 1 | 9 disks show *Dynamic*, data still visible | LDM only rewrites tables. The NTFS volumes don't move | Back up metadata, nothing else yet | Safe starting point |
| 2 | After NIUBI: 0x7B INACCESSIBLE_BOOT_DEVICE, *invalid dynamic pack* | One disk left the LDM pack, so the other databases disagree and `volmgrx` refuses to bring up the boot volume | Convert **all** disks to basic offline ([GPT](03-convert-gpt.md) / [MBR](04-convert-mbr.md)) | Still didn't boot, so the registry needed work too |
| 3 | BootExecute contained `nb-fre` | A pre-boot program from a partition tool that runs before autochk is risky | Restore `autocheck autochk *` | Hook removed |
| 4 | `MountedDevices`, `volmgrx` and the `MDA_NTDRV` service still referenced the old setup | Windows would look for a dynamic pack that no longer exists | From WinRE: delete `MDA_NTDRV` and `PrimaryPackId`. From Linux: rewrite 5 GPT letter entries and drop 2 | Got past 0x7B |
| 5 | Long pause at the boot dots, then **0x69 IO1_INITIALIZATION_FAILED** | The pause points to I/O setup and volume enumeration stalling, not a missing driver. What was still unusual? The **partition numbering gaps** left by deleting the LDM metadata partitions | `sgdisk --sort` on each GPT disk | **Windows booted** |
| 6 | Letters shuffled, clock off | Volumes came back as "new". Linux had written UTC to the hardware clock | [After-boot cleanup](08-after-boot-cleanup.md) | Fixed |

**What did *not* help:** Startup Repair, and retrying boots without changing anything. Fixing the tables and registry alone wasn't enough either, because the numbering gaps still blocked boot.

---

[← 08-after-boot-cleanup.md](08-after-boot-cleanup.md) · [Index](../README.md#table-of-contents) · [10-what-not-to-do.md →](10-what-not-to-do.md)
