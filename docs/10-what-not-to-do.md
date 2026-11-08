# What Not to Do With a Dynamic Boot Disk, and Lessons Learned

> Commands and tools that make a dynamic-disk recovery worse, plus what this recovery taught.

[← 09-troubleshooting-log.md](09-troubleshooting-log.md) · [Index](../README.md#table-of-contents) · [faq.md →](faq.md)

## Ground rules: what NOT to do

- ❌ **Do not** use the "flip byte `0x42` → `0x07`" MBR trick. It ignores where the NTFS volume actually starts and leaves the LDM database in place.
- ❌ **Do not** run `diskpart clean` or `convert basic`. On a dynamic disk with volumes, that means deleting the volumes.
- ❌ **Do not** run `chkdsk /f` while the partition tables are still being fixed. If the boundaries are wrong, it will "repair" (destroy) real data.
- ❌ **Do not** use **Reset this PC** or Startup Repair loops. Neither of them fixes LDM, and they can make things worse.
- ❌ **Do not** install more "free" partition tools on the broken system.
- ✅ Do everything **offline from Linux**, make backups first, and change one thing at a time.


## Lessons learned

- **Disk Management is not a USB wipe tool.** Use `diskpart` with `list disk` and check the size first, or wipe from Linux.
- A dynamic conversion does **not** touch your files. The data stays put and only the tables change, so it's recoverable if you don't panic.
- Be wary of free "convert dynamic → basic" tools. They can install boot-start drivers and BootExecute hooks that outlive their job.
- **Back up first, verify read-only, then change one thing at a time.**
- On GPT, deleting partitions leaves numbering gaps. **`sgdisk --sort`** afterward.
- Reinstall your live-USB tools (`libhivex-bin`, `libwin-hivex-perl`) on every boot.
- Expect drive letters and the clock to be off after the first boot. That's cosmetic.

---

[← 09-troubleshooting-log.md](09-troubleshooting-log.md) · [Index](../README.md#table-of-contents) · [faq.md →](faq.md)
