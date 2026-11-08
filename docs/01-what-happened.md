# What Happened: Accidental Dynamic Disk Conversion, NIUBI, and INACCESSIBLE_BOOT_DEVICE (0x7B)

> How 9 drives, including the Windows 11 boot NVMe, became dynamic disks, and how a free partition tool turned that into a 0x7B boot failure.

[← README](../README.md) · [Index](../README.md#table-of-contents) · [02-backup-first.md →](02-backup-first.md)

## What happened

1. While trying to wipe a USB stick in **Disk Management**, a misclick converted **9 drives** to dynamic disks, the boot NVMe among them. Windows uses LDM (Logical Disk Manager) for dynamic disks:
   - **GPT disks** got a hidden *LDM metadata* partition, and the data partitions were retyped to *LDM data*.
   - **MBR disks** had their partitions replaced by a single type `0x42` entry, with the LDM database at the end of the disk.
2. **NIUBI Partition Editor Free** (portable) was used to convert one MBR data disk back to basic. It left behind a kernel driver, `C:\Windows\System32\MDA_NTDRV.sys` (vendor-signed, manual start), plus `C:\Windows\System32\nb-fre.exe`, and it changed **BootExecute** to run `nb-fre` before the normal `autocheck autochk *`. That way it could finish its work at the next boot, before Windows loads.
3. On the next boot: **`INACCESSIBLE_BOOT_DEVICE`**. The volume manager (`volmgrx`) found an *invalid dynamic pack* because the LDM databases across the disks no longer agreed.

## Symptoms

| Stage | Symptom |
|---|---|
| After NIUBI | `INACCESSIBLE_BOOT_DEVICE` (0x7B) at boot, invalid dynamic disk pack |
| After metadata and registry repair | Long pause at the spinning dots, then **`0x69 IO1_INITIALIZATION_FAILED`** |
| After `sgdisk --sort` | Boots normally. Drive letters shuffled and the clock is off by your UTC offset |

---

[← README](../README.md) · [Index](../README.md#table-of-contents) · [02-backup-first.md →](02-backup-first.md)
