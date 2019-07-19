FROM shadowsocks/shadowsocks-libev
LABEL maintainer="keytouch"

USER root

COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache openssh-server \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -L https://github.com`curl -L https://github.com/xtaci/kcptun/releases/latest | grep -oE '<a\shref.+kcptun-linux-amd64.+\.tar\.gz' | sed 's/<a href="//g'` \
    | tar x -zC /usr/local/bin server_linux_amd64 \
    && mv /usr/local/bin/server_linux_amd64 /usr/local/bin/kcpserver_linux_amd64 \
    && apk del .build-deps \
    && chmod +x /entrypoint.sh

EXPOSE 22 8388 29900/udp

CMD [ "/entrypoint.sh" ]