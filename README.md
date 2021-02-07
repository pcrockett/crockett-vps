## de.crockett.network

This repo contains scripts to automatically provision my own personal cloud service on an Arch VPS. It's one part documentation for myself, one part experimentation, one part learning project, and one part fun.

### Features

As of 2021-02-07, this repo will automatically set up:

* HTTPS-enabled Nginx reverse proxy with an A+ rating according to the [Qualys SSL Labs test][1].
* [Synapse][2] (Matrix homeserver)
* [Element][3] (web-based Matrix client)
* [Coturn][4] (for VoIP calls in Matrix)
* [Sydent][5] (Matrix identity server)
* [WireGuard][6] VPN with NAT and [Quad9][7] DNS

It uses [Podman][8] instead of Docker to run unprivileged containers running as different users.

### Install

You can run the following to set everything up in one step (assuming you're logged in to your server as root):

```bash
curl --proto '=https' \
    --tlsv1.2 \
    --silent \
    --show-error \
    --fail \
    https://raw.githubusercontent.com/pcrockett/de.crockett.network/main/quick-start.sh > quick-start.sh
chmod u+x ./quick-start.sh
./quick-start.sh
```

... or if you want to do things manually:

1. Install git
2. Clone this repo
3. Execute `run.sh`

### Usage

After initial setup, you should see the following new scripts in `/usr/local/bin`:

* `server-cmd`: The main command that allows you to pull changes from the remote Git repo and apply them on the server
* `new-matrix-user`: Create a new matrix user
* `new-wireguard-peer`: Add a new device to the WireGuard VPN

Pass a `--help` parameter to any of these commands to see how they are used.

### TODO:

* [x] Jitsi
* [x] WireGuard VPN
* [x] Firewall
* [x] Auto start on boot
* [ ] Auto updates
* [ ] Backups (mainly Synapse)

[1]: https://www.ssllabs.com/ssltest/
[2]: https://github.com/matrix-org/synapse
[3]: https://github.com/vector-im/element-web
[4]: https://github.com/instrumentisto/coturn-docker-image
[5]: https://github.com/matrix-org/sydent
[6]: https://www.wireguard.com/
[7]: https://www.quad9.net/
[8]: https://podman.io/
