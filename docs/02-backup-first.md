# Back Up First: Live USB Setup, Disk Metadata Backup, and NTFS Boundary Checks

> Boot Ubuntu 24.04, install the tools, back up every disk's partition tables and LDM metadata, and confirm where each NTFS volume starts and ends.

[← 01-what-happened.md](01-what-happened.md) · [Index](../README.md#table-of-contents) · [03-convert-gpt.md →](03-convert-gpt.md)

## Step 0: Prepare the live USB

Boot Ubuntu 24.04 ("Try Ubuntu"). Live sessions don't keep installed packages, so **reinstall these on every live boot**:

```bash
sudo apt update
sudo apt install -y gdisk ntfs-3g libhivex-bin libwin-hivex-perl
```

Identify your disks (names below are placeholders):

```bash
lsblk -o NAME,SIZE,TYPE,PTTYPE,PARTTYPENAME,FSTYPE,LABEL
sudo sgdisk -p /dev/nvmeXn1     # GPT disk
sudo sfdisk -d /dev/sdX         # MBR disk
```

Do **not** mount any Windows volume read-write yet.

## Step 1: Back up all metadata

For **every** affected disk, save the partition table plus the first and last 1 MiB, which hold the MBR/GPT headers and the LDM database. Use the script [`scripts/backup-disk-metadata.sh`](../scripts/backup-disk-metadata.sh), or run these by hand:

```bash
D=/dev/sdX; N=sdX; OUT=/media/ubuntu/USB/backup   # save to a SEPARATE drive
mkdir -p "$OUT"
SECT=$(sudo blockdev --getsz $D)                   # size in 512-byte sectors
sudo dd if=$D of=$OUT/$N-first1MiB.bin bs=512 count=2048
sudo dd if=$D of=$OUT/$N-last1MiB.bin  bs=512 skip=$((SECT-2048)) count=2048
sudo sfdisk -d $D > $OUT/$N.sfdisk 2>/dev/null           # MBR (also works for GPT)
sudo sgdisk --backup=$OUT/$N.sgdisk $D 2>/dev/null       # GPT
sudo sgdisk -p $D > $OUT/$N-print.txt 2>&1
```

Copy the backups off the machine before you continue.

## Step 2: Verify NTFS volume boundaries

Before you rewrite any table, prove where each NTFS volume starts and how big it is. Read-only:

```bash
sudo ntfsresize --info --force --no-action /dev/sdX1
```

It reports the volume size from the NTFS boot sector. The partition you create must start at the **exact** NTFS start sector and be **at least** that size. On MBR disks where the old entry is a single `0x42` partition, find the NTFS boot sector by scanning for `NTFS    ` at the start sectors you'd expect (often 63, 2048, or 34 + the LDM offset). Check with:

```bash
sudo dd if=/dev/sdX bs=512 skip=START count=1 2>/dev/null | xxd | head -3   # expect "NTFS    " at offset 3
```

---

[← 01-what-happened.md](01-what-happened.md) · [Index](../README.md#table-of-contents) · [03-convert-gpt.md →](03-convert-gpt.md)
