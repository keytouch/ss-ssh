#!/bin/sh
ssh-keygen -A
echo "root:${RootPassword:-admin}" | chpasswd
/usr/sbin/sshd -D