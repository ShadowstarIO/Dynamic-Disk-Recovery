# Convert a GPT Dynamic Disk to Basic Without Data Loss (sgdisk)

> Retype LDM data partitions to Basic Data (0700) and delete the LDM metadata partition with sgdisk.

[← 02-backup-first.md](02-backup-first.md) · [Index](../README.md#table-of-contents) · [04-convert-mbr.md →](04-convert-mbr.md)

## Step 3a: GPT disks

On GPT, each data partition is typed **Microsoft LDM data** (`4202`), and there is an extra **LDM metadata** partition (`4201`, usually about 1 MiB). The fix is to retype the data partition(s) to **Microsoft basic data** (`0700`) and delete the metadata partition. The partitions themselves don't move.

```bash
sudo sgdisk -p /dev/sdX          # confirm which number is LDM metadata (4201) and which is LDM data (4202)
```

On the data disks here, **partition 1 was LDM metadata and partition 3 was the data partition**. *Your numbers may differ, so check `sgdisk -p` first.*

⚠️ **WRITES TO DISK**
```bash
sudo sgdisk -t 3:0700 -d 1 /dev/sdX && sudo sgdisk -p /dev/sdX
```

For the **boot disk**, keep the ESP as `EF00` and the MSR as `0C01`, retype the Windows and recovery partitions (recovery = `2700`), and delete the LDM metadata partition. Re-check with `sgdisk -p` and `sgdisk -v`.

> Deleting partitions leaves **gaps in the partition numbers** (for example, Windows ends up as p5 with nothing at p3). That gap caused the 0x69 crash in [Step 5](06-fix-0x69-partition-gaps.md). You can run `sgdisk --sort` right away.

---

[← 02-backup-first.md](02-backup-first.md) · [Index](../README.md#table-of-contents) · [04-convert-mbr.md →](04-convert-mbr.md)
