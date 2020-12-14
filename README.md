# docker-strongswan

A Docker image of IKEv2 VPN server based on [Alpine](https://hub.docker.com/_/alpine).

## How to use this image

Starting a Naplas instance is simple:

```sh
docker run \
    --restart=always \
    --detach \
    --privileged \
    --volume=/lib/modules:/lib/modules \
    --publish=500:500/udp \
    --publish=4500:4500/udp \
    --env HOST="<your-servder-ip>" \
    --name naplas haitunio:strongswan
```

Adding a new user:

```sh
docker exec naplas vpnctl user add <username> <password>
```

Generating CA certificate:

```sh
docker exec naplas vpnctl cert create --type=ca
```

Generating server certificate:

```sh
docker exec naplas vpnctl cert create --type=server