#!/bin/sh
ssh-keygen -A
echo "root:${RootPassword:-admin}" | chpasswd
# STORE transient info to file (TWEAK)
curl -o /service_info.json ${API_URL}
exec /usr/bin/supervisord
