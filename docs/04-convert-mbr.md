# Convert an MBR Dynamic Disk (Type 0x42) to Basic Without Data Loss (sfdisk)

> Rewrite the MBR with sfdisk, keeping the disk signature, using one type-07 partition at the exact NTFS start.

[← 03-convert-gpt.md](03-convert-gpt.md) · [Index](../README.md#table-of-contents) · [05-offline-registry-fixes.md →](05-offline-registry-fixes.md)

## Step 3b: MBR disks

Rewrite the table with `sfdisk` and **keep the disk signature** (`label-id`), because Windows uses it to identify the disk. Create one type `07` partition at the exact NTFS start found in Step 2.

```bash
sudo sfdisk -d /dev/sdX            # note label-id: 0xXXXXXXXX
```

On this machine the old entry was `type=42` starting at sector **63**, but the NTFS boot sector was actually at **2048**. That's why the byte-flip trick would have failed.

⚠️ **WRITES TO DISK**
```bash
printf 'label: dos\nlabel-id: 0xSIGNATURE\nunit: sectors\n\nstart=2048, size=SIZE, type=7\n' | sudo sfdisk --no-reread /dev/sdX
```

`SIZE` comes from `ntfsresize` or the NTFS boot sector, and must be ≥ the sector count `ntfsresize` reports (volume size / 512). Then verify:

```bash
sudo ntfsresize --info --force --no-action /dev/sdX1
sudo ntfsfix -n /dev/sdX1     # -n = no changes
```

The leftover LDM database at the end of the disk is harmless once nothing points at it.

---

[← 03-convert-gpt.md](03-convert-gpt.md) · [Index](../README.md#table-of-contents) · [05-offline-registry-fixes.md →](05-offline-registry-fixes.md)
