FROM alpine
LABEL maintainer="keytouch"

ENV TINI_VERSION v0.18.0
ENV KCP_VER 20200103

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
COPY --from=shadowsocks/shadowsocks-libev /usr/bin/ss-* /usr/bin/
COPY run.sh /
COPY web_info.go /

RUN apk add --no-cache \
    ca-certificates \
    rng-tools \
    $(scanelf --needed --nobanner /usr/bin/ss-* \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u) \
    openssh-server \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && apk add --no-cache --virtual .build-deps go curl \
    && curl -L https://github.com/xtaci/kcptun/releases/download/v${KCP_VER}/kcptun-linux-amd64-${KCP_VER}.tar.gz \
    | tar -xzC /usr/local/bin server_linux_amd64 \
    && mv /usr/local/bin/server_linux_amd64 /usr/local/bin/kcpserver_linux_amd64 \
    && go build web_info.go \
    && apk del .build-deps \
    && chmod +x /run.sh /tini

ENV SS_SERVER_ADDR=0.0.0.0 \
    SS_PORT=8388 \
    SS_PASSWORD=123456 \
    SS_METHOD=chacha20-ietf-poly1305 \
    SS_TIMEOUT=60 \
    SS_DNS="8.8.8.8,8.8.4.4" \
    SS_ARGS= \
    KCP_PORT=29900 \
    KCP_KEY="it's a secrect" \
    KCP_CRYPT=salsa20 \
    KCP_MODE=fast \
    KCP_MTU=1000 \
    KCP_SNDWND=1024 \
    KCP_RCVWND=1024 \
    KCP_DS=0 \
    KCP_PS=0 \
    KCP_ARGS=

EXPOSE 8080 22 8388/tcp 8388/udp 29900/udp

ENTRYPOINT ["/tini", "--"]

CMD [ "/run.sh" ]
