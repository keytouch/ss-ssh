FROM shadowsocks/shadowsocks-libev
LABEL maintainer="keytouch"

USER root

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY web_info.py /web_info.py

RUN apk add --no-cache openssh-server supervisor curl python2 \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && curl -L https://github.com`curl -L https://github.com/xtaci/kcptun/releases/latest | grep -oE '/\S+?kcptun-linux-amd64\S+?\.tar\.gz'` \
    | tar -xzC /usr/local/bin server_linux_amd64 \
    && mv /usr/local/bin/server_linux_amd64 /usr/local/bin/kcpserver_linux_amd64 \
    && apk add --no-cache --virtual .build-deps py2-pip \
    && pip install web.py \
    && apk del .build-deps \
    && chmod +x /entrypoint.sh /web_info.py

ENV SS_SERVER_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_PASSWORD=123456 \
    SS_METHOD=aes-256-gcm \
    SS_TIMEOUT=300 \
    SS_DNS="8.8.8.8,8.8.4.4" \
    KCP_PORT=29900 \
    KCP_KEY="it's a secrect" \
    KCP_CRYPT=aes \
    KCP_MODE=fast \
    KCP_MTU=1350 \
    KCP_SNDWND=1024 \
    KCP_RCVWND=1024 \
    KCP_DS=10 \
    KCP_PS=3

EXPOSE 8080 22 8388 29900/udp

CMD [ "/entrypoint.sh" ]
