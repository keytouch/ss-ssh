#!/bin/sh
ssh-keygen -A
echo "root:${RootPassword:-admin}" | chpasswd

/web_info &

GOGC=20 kcpserver_linux_amd64 -l :$KCP_PORT -t 127.0.0.1:$SS_PORT --crypt $KCP_CRYPT --key "$KCP_KEY" \
    --mode $KCP_MODE --mtu $KCP_MTU --sndwnd $KCP_SNDWND --rcvwnd $KCP_RCVWND \
    --ds $KCP_DS --ps $KCP_PS --quiet \
    $KCP_ARGS &

ss-server -s $SS_SERVER_ADDR -p $SS_PORT -k $SS_PASSWORD -m $SS_METHOD -t $SS_TIMEOUT -d $SS_DNS \
    -u --fast-open $SS_ARGS &

exec /usr/sbin/sshd -D
