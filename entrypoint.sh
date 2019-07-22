#!/bin/sh
ssh-keygen -A
echo "root:${RootPassword:-admin}" | chpasswd
exec /usr/bin/supervisord
