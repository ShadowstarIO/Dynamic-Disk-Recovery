# Dynamic Disk Recovery: Convert a Windows 11 Boot Drive from Dynamic to Basic Without Data Loss

Fix **INACCESSIBLE_BOOT_DEVICE (0x7B)**, **"Invalid dynamic pack"**, and **IO1_INITIALIZATION_FAILED (0x69)** after an accidental dynamic-disk conversion. Everything is done offline from an Ubuntu live USB, with no reinstall and no data loss.

> ⚠️ This is a real recovery from one machine. Check every partition number and sector offset against **your** disks, and **back up first**. Commands that write to disk are marked ⚠️.

## The problem
While a USB stick was being wiped in Windows **Disk Management**, 9 drives, including the **boot NVMe**, were converted to **dynamic disks** (LDM). **NIUBI Partition Editor Free** was then used to convert one MBR disk back. It left a `BootExecute` hook (`nb-fre`) and an `MDA_NTDRV` driver service, and it broke the dynamic pack. Windows stopped booting.

## Symptoms
| Stage | Exact error |
|---|---|
| After the NIUBI conversion | `INACCESSIBLE_BOOT_DEVICE` (0x7B): volmgrx reports **invalid dynamic pack** |
| After the table and registry repairs | Long pause at the spinning dots, then `IO1_INITIALIZATION_FAILED` (0x69) |
| After `sgdisk --sort` | Boots. Drive letters shuffled, clock off by the UTC offset |

## Quick path
1. **Back up** partition tables and the first/last 1 MiB of every disk from a live USB → [02](docs/02-backup-first.md)
2. **GPT:** `sgdisk -t 3:0700 -d 1` (retype LDM data, delete LDM metadata) → [03](docs/03-convert-gpt.md)
3. **MBR:** rewrite with `sfdisk`, keeping `label-id`, with one type-07 partition at the true NTFS start → [04](docs/04-convert-mbr.md)
4. **Registry (offline):** restore `BootExecute`, delete the `MDA_NTDRV` service and `volmgrx\PrimaryPackId`, rewrite stale `MountedDevices` → [05](docs/05-offline-registry-fixes.md)
5. **0x69:** close GPT numbering gaps with `sgdisk --sort` → [06](docs/06-fix-0x69-partition-gaps.md)
6. **Verify read-only, reboot, clean up** → [07](docs/07-verify-before-reboot.md), [08](docs/08-after-boot-cleanup.md)

## Table of contents
- [01 · What happened](docs/01-what-happened.md)
- [02 · Back up first](docs/02-backup-first.md)
- [03 · Convert GPT dynamic disks](docs/03-convert-gpt.md)
- [04 · Convert MBR dynamic disks](docs/04-convert-mbr.md)
- [05 · Offline registry fixes](docs/05-offline-registry-fixes.md)
- [06 · Fix 0x69 (partition gaps)](docs/06-fix-0x69-partition-gaps.md)
- [07 · Verify before reboot](docs/07-verify-before-reboot.md)
- [08 · After-boot cleanup](docs/08-after-boot-cleanup.md)
- [09 · Troubleshooting log](docs/09-troubleshooting-log.md)
- [10 · What not to do](docs/10-what-not-to-do.md)
- [FAQ](docs/faq.md) · [References and credits](docs/references.md)
- Scripts: [backup](scripts/backup-disk-metadata.sh) · [GUID → MountedDevices](scripts/guid-to-mounteddevices.sh) · [read-only verify](scripts/verify-readonly.sh)
- Machine-readable: [llms.txt](llms.txt) · [data/recovery-steps.json](data/recovery-steps.json)

## Credits
Written by **Xoza Shadow**, with help from his AI tech-support assistant, **Patch**. See [references and credits](docs/references.md). To cite this guide, see [CITATION.cff](CITATION.cff).

Want your own AI tech-support assistant like Patch? [Get the Patch · Tech Support bot template](https://x.ai/bot/bLGDpzvR9jWwDQrcgTIJp).

## License
Docs: [CC BY 4.0](LICENSE). Scripts are provided as-is; read them before running.
