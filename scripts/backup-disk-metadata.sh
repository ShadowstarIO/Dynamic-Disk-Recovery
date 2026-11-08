#!/usr/bin/env bash
# Read-only on source disks. Backs up partition tables + first/last 1 MiB of each disk.
# Usage: sudo ./backup-disk-metadata.sh /path/to/backup/dir /dev/sdX /dev/nvmeXn1 ...
set -euo pipefail
OUT=$1; shift; mkdir -p "$OUT"
for D in "$@"; do
  N=$(basename "$D"); S=$(blockdev --getsz "$D")
  dd if="$D" of="$OUT/$N-first1MiB.bin" bs=512 count=2048 status=none
  dd if="$D" of="$OUT/$N-last1MiB.bin"  bs=512 skip=$((S-2048)) count=2048 status=none
  sfdisk -d "$D" > "$OUT/$N.sfdisk" 2>/dev/null || true
  sgdisk --backup="$OUT/$N.sgdisk" "$D" >/dev/null 2>&1 || true
  sgdisk -p "$D" > "$OUT/$N-print.txt" 2>&1 || true
  echo "backed up $D ($S sectors)"
done
sha256sum "$OUT"/* > "$OUT/SHA256SUMS"
