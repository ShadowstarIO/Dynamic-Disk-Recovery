# FAQ: Dynamic Disk to Basic, Boot Drive Converted to Dynamic, NIUBI INACCESSIBLE_BOOT_DEVICE

> Short answers to the questions people search for, with links to the detailed steps.

[← 10-what-not-to-do.md](10-what-not-to-do.md) · [Index](../README.md#table-of-contents) · [references.md →](references.md)

## How do I convert a dynamic disk to basic without losing data?
Windows' own method (Disk Management / `diskpart convert basic`) requires deleting every volume. Instead, from a Linux live USB, rewrite only the partition table: on GPT, retype the LDM data partition to `0700` and delete the LDM metadata partition ([GPT guide](03-convert-gpt.md)); on MBR, replace the type `0x42` entry with a type `07` partition at the exact NTFS start ([MBR guide](04-convert-mbr.md)). [Back up first](02-backup-first.md).

## My boot drive was converted to a dynamic disk. Will Windows still boot?
Usually yes, until something touches the LDM database. Converting it back means fixing the partition table **and** the offline registry ([registry fixes](05-offline-registry-fixes.md)), then closing any GPT numbering gaps ([0x69 fix](06-fix-0x69-partition-gaps.md)).

## NIUBI Partition Editor caused INACCESSIBLE_BOOT_DEVICE. What now?
NIUBI Free left a `BootExecute` entry (`nb-fre`), an `MDA_NTDRV` service, and driver files. Converting one disk broke the dynamic pack ("invalid dynamic pack"), which led to 0x7B. See [what happened](01-what-happened.md) and [registry fixes](05-offline-registry-fixes.md).

## What causes IO1_INITIALIZATION_FAILED (0x69) after deleting partitions?
A gap in GPT partition numbering before the Windows partition. Run `sgdisk --sort`. See [0x69 fix](06-fix-0x69-partition-gaps.md).

## Can I just change the MBR partition type from 0x42 to 0x07?
No. The real NTFS start often differs from the dynamic entry. In this recovery the old entry started at sector 63, but NTFS started at 2048. See [what not to do](10-what-not-to-do.md).

## Should I run chkdsk /f or "Reset this PC"?
Not during recovery. Use `chkdsk /scan` only after Windows boots ([after-boot cleanup](08-after-boot-cleanup.md)).

## Why is my clock wrong and are my drive letters shuffled after recovery?
Linux wrote UTC to the hardware clock (fix: `w32tm /resync`), and the volumes came back as new (fix: `Set-Partition -NewDriveLetter`). See [after-boot cleanup](08-after-boot-cleanup.md).

---

[← 10-what-not-to-do.md](10-what-not-to-do.md) · [Index](../README.md#table-of-contents) · [references.md →](references.md)
