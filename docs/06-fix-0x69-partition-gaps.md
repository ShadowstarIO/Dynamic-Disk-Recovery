# Fix IO1_INITIALIZATION_FAILED (0x69) After Deleting GPT Partitions: sgdisk --sort

> Gaps in GPT partition numbering before the Windows partition cause 0x69. Renumber the partitions with sgdisk --sort.

[← 05-offline-registry-fixes.md](05-offline-registry-fixes.md) · [Index](../README.md#table-of-contents) · [07-verify-before-reboot.md →](07-verify-before-reboot.md)

## Step 5: Fix 0x69 IO1_INITIALIZATION_FAILED

With the tables and registry fixed, Windows sat at the boot dots for a long time and then stopped with **0x69 IO1_INITIALIZATION_FAILED**. The cause was **gaps in GPT partition numbering** left by deleting the LDM metadata partitions (for example, the Windows partition at p5 with an empty slot before it). Windows' early I/O setup didn't handle that.

A Super User case ([question 1766064](https://superuser.com/questions/1766064)) matches exactly. After a GPT partition was deleted with `sgdisk`, Windows 10 crashed with IO1_INITIALIZATION_FAILED, and `sgdisk -s` (sort) fixed it. The poster found by trial and error that **any hole in the numbering *before* the Windows partition** causes the crash, while a hole after it doesn't. Sorting doesn't affect the BCD entries. Startup Repair could not fix it, and Disk Management renumbers partitions by itself, which is why the problem never shows up when you delete partitions from Windows.

Preview first (read-only):
```bash
sudo sgdisk --print --verify /dev/X
sudo sgdisk --pretend --sort --print /dev/X
```
⚠️ **WRITES TO DISK** (renumbers entries only; data is untouched):
```bash
for d in <disks>; do sudo sgdisk --sort /dev/$d; done
```
Do this on **every** GPT disk you fixed. Partition GUIDs don't change, so the `DMIO:ID:` entries stay valid. Next boot: **Windows started.**

---

[← 05-offline-registry-fixes.md](05-offline-registry-fixes.md) · [Index](../README.md#table-of-contents) · [07-verify-before-reboot.md →](07-verify-before-reboot.md)
