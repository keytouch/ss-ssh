#!/bin/sh
ssh-keygen -A
echo "root:${RootPassword:-admin}" | chpasswd
/usr/bin/supervisord