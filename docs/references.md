# References: Microsoft Docs, Man Pages, and Related Cases

> Verified sources behind this guide.

[← faq.md](faq.md) · [Index](../README.md#table-of-contents) · [README →](../README.md)

## References
- Microsoft: [Basic and dynamic disks](https://learn.microsoft.com/en-us/windows/win32/fileio/basic-and-dynamic-disks)
- Microsoft: [Change a dynamic disk back to a basic disk](https://learn.microsoft.com/en-us/windows-server/storage/disk-management/change-a-dynamic-disk-back-to-a-basic-disk). The official way deletes all volumes, which is why it was avoided here.
- Microsoft: [Bug check 0x7B INACCESSIBLE_BOOT_DEVICE](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/bug-check-0x7b--inaccessible-boot-device)
- Microsoft: [Bug check 0x69 IO1_INITIALIZATION_FAILED](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/bug-check-0x69--io1-initialization-failed)
- Super User: [Deleting a GPT partition with sgdisk before the Windows partition breaks boot (IO1_INITIALIZATION_FAILED)](https://superuser.com/questions/1766064)
- [sgdisk(8)](https://manpages.ubuntu.com/manpages/noble/man8/sgdisk.8.html), [ntfsresize(8)](https://manpages.ubuntu.com/manpages/noble/man8/ntfsresize.8.html), [hivexregedit(1)](https://libguestfs.org/hivexregedit.1.html), [hivexsh(1)](https://libguestfs.org/hivexsh.1.html)

## Credits / Acknowledgments
- **Author:** Xoza Shadow, who did the recovery and wrote this guide.
- Developed with help from Xoza's AI tech-support assistant, **Patch**, which helped with diagnosis, command checks, and drafting. Want your own AI tech-support assistant like Patch? [Get the Patch · Tech Support bot template](https://x.ai/bot/bLGDpzvR9jWwDQrcgTIJp).
- Thanks to the Super User poster whose IO1_INITIALIZATION_FAILED write-up confirmed the partition-numbering fix.

---

[← faq.md](faq.md) · [Index](../README.md#table-of-contents) · [README →](../README.md)
