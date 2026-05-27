#!/bin/bash
echo "=== Storage Health Check ==="
echo "Date: $(date)"
echo
echo "=== Disk Usage ==="
df -h | grep -E "(Filesystem|vg_data)"
echo
echo "=== LVM Status ==="
sudo vgs
sudo lvs
echo
echo "=== Mount Status ==="
mount | grep vg_data
