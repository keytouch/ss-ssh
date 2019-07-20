FROM shadowsocks/shadowsocks-libev
LABEL maintainer="keytouch"

USER root

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache openssh-server supervisor \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -L https://github.com`curl -L https://github.com/xtaci/kcptun/releases/latest | egrep -o '<a\shref.+kcptun-linux-amd64.+\.tar\.gz' | sed 's/<a href="//g'` \
    | tar x -zC /usr/local/bin server_linux_amd64 \
    && mv /usr/local/bin/server_linux_amd64 /usr/local/bin/kcpserver_linux_amd64 \
    && apk del .build-deps \
    && chmod +x /entrypoint.sh

ENV SS_SERVER_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_PASSWORD=123456 \
    SS_METHOD=aes-256-gcm \
    SS_TIMEOUT=300 \
    KCP_KEY=123456 \
    KCP_CRYPT=aes \
    KCP_MODE=fast \
    KCP_MTU=1350 \
    KCP_SNDWND=256 \
    KCP_RCVWND=256 \
    KCP_DS=10 \
    KCP_PS=3

EXPOSE 22 8388 29900/udp

CMD [ "/entrypoint.sh" ]