#!/bin/bash
# Nạp module usblp
modprobe usblp
# Xóa các PID cũ nếu có để tránh xung đột
rm -f /var/run/ccpd.pid
# Khởi động ccpd
/usr/sbin/ccpd
