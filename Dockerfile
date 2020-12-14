FROM alpine:latest

ENV STRONGSWAN_RELEASE=https://download.strongswan.org/strongswan.tar.bz2 \
    PKIDIR="/etc/pki/strongswan" \
    ORGANIZATION="Haitun.io" \
    CA_NAME="Haitun IKEv2 VPN Root CA"

VOLUME $PKIDIR

RUN set -x && \
    apk add --update --no-cache \
        curl \
        iptables && \
    apk add --update --no-cache --virtual .build-deps python3 \
        build-base \
        ca-certificates \
        curl-dev \
        iproute2 \
        iptables-dev \
        openssl \
        openssl-dev && \
    mkdir -p /tmp/strongswan && \
    curl -Lo /tmp/strongswan.tar.bz2 $STRONGSWAN_RELEASE && \
    tar --strip-components=1 -C /tmp/strongswan -xjf /tmp/strongswan.tar.bz2 && \
    cd /tmp/strongswan && \
    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --libexecdir=/usr/lib \
        --with-ipsecdir=/usr/lib/strongswan \
        --enable-aesni \
        --enable-chapoly \
        --enable-cmd \
        --enable-curl \
        --enable-dhcp \
        --enable-eap-dynamic \
        --enable-eap-identity \
        --enable-eap-md5 \
        --enable-eap-mschapv2 \
        --enable-eap-radius \
        --enable-eap-tls \
        --enable-farp \
        --enable-files \
        --enable-gcm \
        --enable-md4 \
        --enable-newhope \
        --enable-ntru \
        --enable-openssl \
        --enable-sha3 \
        --enable-shared \
        --disable-aes \
        --disable-des \
        --disable-gmp \
        --disable-hmac \
        --disable-ikev1 \
        --disable-md5 \
        --disable-rc2 \
        --disable-sha1 \
        --disable-sha2 \
        --disable-static && \
    make && make install && \
    cd - && \
    rm -rf /tmp/* && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

COPY ./etc/ipsec.conf /etc/ipsec.conf
COPY ./etc/charon-logging.conf /etc/strongswan.d/charon-logging.conf
COPY ./etc/charon.conf /etc/strongswan.d/charon.conf
COPY ./etc/ipsec.secrets /etc/ipsec.secrets

COPY ./scripts/vpnctl /usr/local/bin/vpnctl
RUN chmod u+x /usr/local/bin/vpnctl

EXPOSE 500:500/udp
EXPOSE 4500:4500/udp

COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

